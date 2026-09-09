import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';
import 'package:web/web.dart' as web;

import 'conversions.dart';
import 'interop/mmrgl.dart';
import 'polyline.dart';

/// Изображение стиля: хранится, чтобы вернуть его после смены стиля.
class _StyleImage {
  _StyleImage(this.element, this.scale);

  final web.HTMLImageElement element;
  final double scale;
}

/// Слой стиля: хранится вместе с местом вставки и видимостью.
class _StyleLayer {
  _StyleLayer(this.json, this.beforeLayerId);

  final Map<String, Object?> json;
  final String? beforeLayerId;

  String get id => json['id']! as String;

  bool visible = true;
}

/// Одна карта на странице: обёртка над `mmrgl.Map`.
///
/// Кроме вызовов SDK класс держит состояние карты — картинки, источники,
/// слои, маркеры и индикатор пользователя. Это не кэш ради скорости:
/// `setStyle` в MMR GL JS выбрасывает всё, что было добавлено к прошлому
/// стилю, и без сохранённого состояния карта после смены стиля потеряла бы
/// объекты приложения.
class VkWebMapInstance {
  /// Создаёт карту в [container] и подписывается на её события.
  VkWebMapInstance({
    required this.viewId,
    required this.container,
    required VkMapInitialConfiguration configuration,
    required void Function(VkMapEvent event) onEvent,
  }) : _onEvent = onEvent {
    _appliedStyle = configuration.configuration.style ?? _appliedStyle;
    final JSObject options = jsObject(_creationOptions(configuration));
    options.setProperty('container'.toJS, container);
    _map = MmrMap(options);
    _applyGestures(configuration.configuration);
    _applyControls(configuration.configuration, initial: true);
    _listen();
    _observeResize();
  }

  /// Идентификатор platform view, к которому привязана карта.
  final int viewId;

  /// Элемент документа, в котором живёт карта.
  final web.HTMLElement container;

  final void Function(VkMapEvent event) _onEvent;

  late final MmrMap _map;

  final Map<String, _StyleImage> _images = <String, _StyleImage>{};

  /// Картинки, о нехватке которых уже сообщили приложению.
  ///
  /// Карта просит недостающую картинку на каждой перерисовке, поэтому без
  /// этого набора поток событий забился бы одной и той же ошибкой.
  final Set<String> _reportedMissingImages = <String>{};
  final Map<String, String> _sources = <String, String>{};
  final List<_StyleLayer> _layers = <_StyleLayer>[];

  /// Стиль, который сейчас стоит на карте.
  ///
  /// Незаданный стиль на web означает основной: без стиля карта не
  /// загружается вовсе.
  VkMapStyle _appliedStyle = const VkMapStyle.predefined(
    VkPredefinedStyle.main,
  );

  Set<VkMarker> _markers = const <VkMarker>{};
  VkLatLon? _userLocation;
  double? _userBearing;
  double? _userAccuracy;
  bool _userVisible = true;
  bool _userLayersNeeded = false;

  VkMapMode _mode = VkMapMode.free;
  VkLogoAlignment _logoAlignment = VkLogoAlignment.bottomRight;
  VkEdgeInsets _logoInsets = VkEdgeInsets.zero;
  bool _compassEnabled = true;
  bool _zoomButtonsEnabled = false;
  bool _currentLocationButtonEnabled = false;

  JSObject? _navigationControl;
  JSObject? _geolocateControl;
  JSObject? _logoControl;
  web.ResizeObserver? _resizeObserver;

  Completer<VkCameraAnimationResult>? _cameraCompleter;
  bool _disposed = false;

  /// Собран ли стиль карты.
  ///
  /// До этого момента источники, слои и картинки в карту не отдаются:
  /// `MMR GL JS` отвечает на них ошибкой «стиль ещё не загружен».
  /// Приложение об этом знать не должно — вызовы складываются в состояние
  /// и уезжают в карту сразу после загрузки стиля.
  bool _styleReady = false;

  Map<String, Object?> _creationOptions(VkMapInitialConfiguration initial) {
    final VkMapConfiguration configuration = initial.configuration;
    final VkCameraPosition camera = initial.initialCameraPosition;
    return <String, Object?>{
      'center': VkWebConversions.lngLat(camera.target),
      'zoom': camera.zoom,
      'bearing': camera.bearing,
      'pitch': camera.pitch,
      // Стиль обязателен: без него web-карта не загружается и не шлёт
      // `load`. Незаданный стиль означает «взять основной из SDK» — на
      // мобильных платформах его подставляет сам нативный SDK.
      'style': VkWebConversions.styleToJs(
        configuration.style ??
            const VkMapStyle.predefined(VkPredefinedStyle.main),
      ),
      if (configuration.minZoom != null) 'minZoom': configuration.minZoom,
      if (configuration.maxZoom != null) 'maxZoom': configuration.maxZoom,
      // Логотип VK карта ставит сама: скрыть его нельзя (решение Р-7),
      // а угол задаётся штатной опцией SDK.
      'mmrglLogo': true,
      'logoPosition': VkWebConversions.controlPosition(
        configuration.logoAlignment ?? VkLogoAlignment.bottomRight,
      ),
      'interactive': true,
      'trackResize': true,
    };
  }

  // --- события ------------------------------------------------------------

  void _listen() {
    _map.on(
      'load',
      ((MmrMapEvent _) {
        // Стиль собран: с этого момента источники, слои и картинки можно
        // отдавать карте, а всё, что приложение просило раньше, уезжает
        // в неё из состояния плагина.
        _styleReady = true;
        _onEvent(const VkMapShownEvent());
        _onEvent(const VkStyleAppliedEvent());
        _restoreStyleContent();
      }).toJS,
    );

    _map.on(
      'click',
      ((MmrMapEvent event) => _handleTap(event, long: false)).toJS,
    );

    _map.on(
      'contextmenu',
      ((MmrMapEvent event) => _handleTap(event, long: true)).toJS,
    );

    _map.on(
      'movestart',
      ((MmrMapEvent event) {
        if (event.originalEvent != null) {
          // Пользователь перехватил камеру: обещанное приложению перемещение
          // уже не состоится.
          _completeCamera(VkCameraAnimationResult.cancelled);
        }
        _emitCameraMove(event, VkCameraMovingPhase.started);
      }).toJS,
    );

    _map.on(
      'move',
      ((MmrMapEvent event) => _emitCameraMove(
        event,
        VkCameraMovingPhase.moving,
      )).toJS,
    );

    _map.on(
      'moveend',
      ((MmrMapEvent event) {
        _completeCamera(VkCameraAnimationResult.finished);
        _emitCameraMove(event, VkCameraMovingPhase.allCompleted);
      }).toJS,
    );

    // Маркер с картинкой, которой нет в стиле, рисуется пустотой. SDK
    // сообщает об этом отдельным событием — без пересказа наружу
    // приложение видело бы, что маркер «не появился», и не понимало почему.
    _map.on(
      'styleimagemissing',
      ((MmrMapEvent event) {
        final String imageId = event.id ?? '';
        if (!VkWebConversions.shouldReportMissingImage(
          imageId,
          markers: _markers,
          addedImages: _images.keys,
        )) {
          return;
        }
        if (!_reportedMissingImages.add(imageId)) {
          return;
        }
        _onEvent(
          VkMapErrorEvent(
            code: 'style-image-missing',
            message:
                'В стиле карты нет изображения «$imageId», поэтому маркеры '
                'с этим imageId не рисуются. Добавьте картинку через '
                'controller.addStyleImage("$imageId", pngBytes).',
          ),
        );
      }).toJS,
    );

    _map.on(
      'error',
      ((MmrMapEvent event) {
        _onEvent(
          VkMapErrorEvent(
            code: 'mmrgl',
            message: event.error?.message ?? 'Ошибка карты без описания',
          ),
        );
      }).toJS,
    );
  }

  void _handleTap(MmrMapEvent event, {required bool long}) {
    final MmrLngLat? lngLat = event.lngLat;
    final MmrPoint? point = event.point;
    if (lngLat == null || point == null) {
      return;
    }
    final VkLatLon position = VkLatLon(lngLat.lat, lngLat.lng);

    final String? markerId = long ? null : _markerIdAt(point);
    if (markerId != null) {
      _onEvent(
        VkMarkerTapEvent(
          markerId: VkMarkerId(markerId),
          position: _markerPosition(markerId) ?? position,
        ),
      );
      return;
    }

    _onEvent(
      VkMapTapEvent(
        position: position,
        screenPoint: VkScreenPoint(point.x, point.y),
        isLongTap: long,
      ),
    );
  }

  /// Идентификатор маркера под точкой [point], если он там есть.
  ///
  /// Касание маркера ищется здесь, а не отдельной подпиской на слой:
  /// иначе одно нажатие пришло бы приложению дважды — и как касание карты,
  /// и как касание маркера.
  String? _markerIdAt(MmrPoint point) {
    if (_map.getLayer(VkWebConversions.markersLayerId) == null) {
      return null;
    }
    final List<MmrFeature> features = _map
        .queryRenderedFeatures(
          point,
          jsObject(<String, Object?>{
            'layers': <String>[VkWebConversions.markersLayerId],
          }),
        )
        .toDart;
    if (features.isEmpty) {
      return null;
    }
    final JSAny? id = features.first.properties?.getProperty('markerId'.toJS);
    return id.isA<JSString>() ? (id! as JSString).toDart : null;
  }

  VkLatLon? _markerPosition(String markerId) {
    for (final VkMarker marker in _markers) {
      if (marker.markerId.value == markerId) {
        return marker.position;
      }
    }
    return null;
  }

  void _emitCameraMove(MmrMapEvent event, VkCameraMovingPhase phase) {
    _onEvent(
      VkCameraMoveEvent(
        position: cameraPosition(),
        reason: _movingReason(event),
        phase: phase,
      ),
    );
  }

  VkCameraMovingReason _movingReason(MmrMapEvent event) {
    if (event.originalEvent != null) {
      return VkCameraMovingReason.gesture;
    }
    if (event.isFollowMove ?? false) {
      return VkCameraMovingReason.followMode;
    }
    if (event.isApiMove ?? false) {
      return VkCameraMovingReason.api;
    }
    return VkCameraMovingReason.unknown;
  }

  void _observeResize() {
    // Карта создаётся раньше, чем Flutter выдаст элементу размер, поэтому
    // без пересчёта она осталась бы нулевой.
    final web.ResizeObserver observer = web.ResizeObserver(
      ((JSAny _, JSAny _) {
        if (!_disposed) {
          _map.resize();
        }
      }).toJS,
    );
    observer.observe(container);
    _resizeObserver = observer;
  }

  // --- камера -------------------------------------------------------------

  /// Текущее положение камеры.
  VkCameraPosition cameraPosition() {
    final MmrLngLat center = _map.getCenter();
    return VkCameraPosition(
      target: VkLatLon(center.lat, center.lng),
      zoom: _map.getZoom(),
      bearing: _map.getBearing(),
      pitch: _map.getPitch(),
    );
  }

  /// Границы видимой области.
  VkLatLonBounds visibleBounds() {
    final MmrLngLatBounds bounds = _map.getBounds();
    final MmrLngLat southwest = bounds.getSouthWest();
    final MmrLngLat northeast = bounds.getNorthEast();
    return VkLatLonBounds(
      southwest: VkLatLon(southwest.lat, southwest.lng),
      northeast: VkLatLon(northeast.lat, northeast.lng),
    );
  }

  /// Координата по точке на экране.
  VkLatLon coordinateForScreenPoint(VkScreenPoint point) {
    final MmrLngLat result = _map.unproject(jsList(<double>[point.x, point.y]));
    return VkLatLon(result.lat, result.lng);
  }

  /// Точка на экране по координате.
  ///
  /// `null`, если координата за камерой: для таких точек библиотека отдаёт
  /// `Number.MAX_VALUE`.
  VkScreenPoint? screenPointForCoordinate(VkLatLon coordinate) {
    final MmrPoint point = _map.project(
      jsList(VkWebConversions.lngLat(coordinate)),
    );
    const double maxValue = 1.7976931348623157e308;
    if (point.x >= maxValue || point.y >= maxValue) {
      return null;
    }
    return VkScreenPoint(point.x, point.y);
  }

  /// Перемещает камеру и ждёт конца перемещения.
  Future<VkCameraAnimationResult> moveCamera({
    VkLatLon? target,
    VkCameraOptions? options,
    VkAnimationOptions? animation,
    bool followMode = false,
  }) {
    final Map<String, Object?> camera = VkWebConversions.cameraOptions(
      target: target,
      options: options,
    );
    if (camera.isEmpty) {
      return Future<VkCameraAnimationResult>.value(
        VkCameraAnimationResult.finished,
      );
    }
    final Map<String, Object?> animationOptions =
        VkWebConversions.animationOptions(animation);
    final JSObject eventData = jsObject(<String, Object?>{
      'vkApiMove': !followMode,
      'vkFollowMove': followMode,
    });

    final Completer<VkCameraAnimationResult> completer = _startCameraMove();
    if (animationOptions['animate'] == false) {
      _map.jumpTo(jsObject(camera), eventData);
    } else {
      _map.easeTo(
        jsObject(<String, Object?>{...camera, ...animationOptions}),
        eventData,
      );
    }
    return completer.future;
  }

  /// Вписывает область в видимую часть карты.
  Future<VkCameraAnimationResult> fitBounds(
    VkLatLonBounds bounds, {
    VkEdgeInsets padding = VkEdgeInsets.zero,
    VkAnimationOptions? animation,
  }) {
    final Map<String, Object?> options = <String, Object?>{
      'padding': VkWebConversions.padding(padding),
      // Без `linear` карта улетает по дуге `flyTo`, и заданная длительность
      // анимации перестаёт что-либо значить.
      'linear': true,
      ...VkWebConversions.animationOptions(animation),
    };

    final Completer<VkCameraAnimationResult> completer = _startCameraMove();
    _map.fitBounds(
      jsList(VkWebConversions.bounds(bounds)),
      jsObject(options),
      jsObject(<String, Object?>{'vkApiMove': true}),
    );
    return completer.future;
  }

  Completer<VkCameraAnimationResult> _startCameraMove() {
    // Новое перемещение отменяет предыдущее: у карты одна камера, и
    // приложение должно узнать, что прошлое обещание не выполнено.
    _completeCamera(VkCameraAnimationResult.cancelled);
    final Completer<VkCameraAnimationResult> completer =
        Completer<VkCameraAnimationResult>();
    _cameraCompleter = completer;
    return completer;
  }

  void _completeCamera(VkCameraAnimationResult result) {
    final Completer<VkCameraAnimationResult>? completer = _cameraCompleter;
    _cameraCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }

  // --- настройки ----------------------------------------------------------

  /// Применяет изменившиеся настройки карты.
  Future<void> updateConfiguration(VkMapConfiguration configuration) async {
    if (configuration.minZoom != null) {
      _map.setMinZoom(configuration.minZoom);
    }
    if (configuration.maxZoom != null) {
      _map.setMaxZoom(configuration.maxZoom);
    }
    if (configuration.padding case final VkEdgeInsets padding) {
      _map.setPadding(jsObject(VkWebConversions.padding(padding)));
    }
    _applyGestures(configuration);
    _applyControls(configuration, initial: false);

    if (configuration.style case final VkMapStyle style) {
      await setStyle(style);
    }
  }

  void _applyGestures(VkMapConfiguration configuration) {
    if (configuration.scrollGesturesEnabled case final bool enabled) {
      _toggle(_map.dragPan, enabled);
      _toggle(_map.keyboard, enabled);
    }
    if (configuration.zoomGesturesEnabled case final bool enabled) {
      _toggle(_map.scrollZoom, enabled);
      _toggle(_map.doubleClickZoom, enabled);
      _toggle(_map.touchZoomRotate, enabled);
      _toggle(_map.boxZoom, enabled);
    }
    if (configuration.rotateGesturesEnabled case final bool enabled) {
      _toggle(_map.dragRotate, enabled);
      _toggle(_map.touchPitch, enabled);
      // Поворот двумя пальцами живёт внутри обработчика зума и выключается
      // отдельным методом; в сборках без него поворот касаниями остаётся.
      final JSObject handler = _map.touchZoomRotate;
      final String method = enabled ? 'enableRotation' : 'disableRotation';
      if (handler.has(method)) {
        handler.callMethod<JSAny?>(method.toJS);
      }
    }
  }

  void _toggle(MmrHandler handler, bool enabled) {
    if (enabled) {
      handler.enable();
    } else {
      handler.disable();
    }
  }

  void _applyControls(
    VkMapConfiguration configuration, {
    required bool initial,
  }) {
    bool navigationChanged = initial;
    if (configuration.compassEnabled case final bool value) {
      navigationChanged |= value != _compassEnabled;
      _compassEnabled = value;
    }
    if (configuration.zoomButtonsEnabled case final bool value) {
      navigationChanged |= value != _zoomButtonsEnabled;
      _zoomButtonsEnabled = value;
    }
    if (navigationChanged) {
      _rebuildNavigationControl();
    }

    if (configuration.currentLocationButtonEnabled case final bool value) {
      if (initial || value != _currentLocationButtonEnabled) {
        _currentLocationButtonEnabled = value;
        _rebuildGeolocateControl();
      }
    }

    bool logoChanged = initial;
    if (configuration.logoAlignment case final VkLogoAlignment value) {
      logoChanged |= value != _logoAlignment;
      _logoAlignment = value;
    }
    if (configuration.logoInsets case final VkEdgeInsets value) {
      logoChanged |= value != _logoInsets;
      _logoInsets = value;
    }
    if (logoChanged) {
      _rebuildLogoControl(initial: initial);
    }
  }

  void _rebuildNavigationControl() {
    final JSObject? previous = _navigationControl;
    if (previous != null) {
      _map.removeControl(previous);
      _navigationControl = null;
    }
    if (!_compassEnabled && !_zoomButtonsEnabled) {
      return;
    }
    final JSObject control = MmrNavigationControl(
      jsObject(<String, Object?>{
        'showCompass': _compassEnabled,
        'showZoom': _zoomButtonsEnabled,
      }),
    );
    _navigationControl = control;
    _map.addControl(control, 'top-right');
  }

  void _rebuildGeolocateControl() {
    final JSObject? previous = _geolocateControl;
    if (previous != null) {
      _map.removeControl(previous);
      _geolocateControl = null;
    }
    if (!_currentLocationButtonEnabled) {
      return;
    }
    final JSObject control = MmrGeolocateControl(
      jsObject(<String, Object?>{
        'trackUserLocation': true,
        'showUserLocation': true,
      }),
    );
    _geolocateControl = control;
    _map.addControl(control, 'top-right');
  }

  void _rebuildLogoControl({required bool initial}) {
    if (!hasLogoControl) {
      // Логотип карта нарисует сама, но переставить его нечем.
      return;
    }
    if (initial && _logoInsets == VkEdgeInsets.zero) {
      // Логотип уже стоит где нужно: карта добавила его при создании по
      // опции `logoPosition`, а отступов от него не требуется.
      return;
    }

    final JSObject? previous = _logoControl;
    if (previous != null) {
      _map.removeControl(previous);
    } else {
      // Свой блок заменяет тот, что карта добавила сама: иначе логотипов
      // на карте станет два.
      _removeOwnLogoControl();
    }

    final JSObject control = _logoControlWith(_logoInsets);
    _logoControl = control;
    _map.addControl(control, VkWebConversions.controlPosition(_logoAlignment));
  }

  /// Убирает логотип, который карта добавила сама при создании.
  ///
  /// Ссылки на него SDK наружу не отдаёт, поэтому элемент удаляется из
  /// документа напрямую — иначе логотипов стало бы два.
  void _removeOwnLogoControl() {
    final web.Element? element = container.querySelector('.mmrgl-ctrl-logos');
    element?.remove();
  }

  /// Блок с логотипом, обёрнутый в собственный контейнер с отступами.
  JSObject _logoControlWith(VkEdgeInsets insets) {
    final MmrLogoControl inner = MmrLogoControl();
    final JSObject control = JSObject();
    control.setProperty(
      'onAdd'.toJS,
      ((MmrMap map) {
        final web.HTMLElement element = inner.onAdd(map);
        final web.HTMLDivElement wrapper = web.HTMLDivElement();
        wrapper.style
          ..marginLeft = '${insets.left}px'
          ..marginTop = '${insets.top}px'
          ..marginRight = '${insets.right}px'
          ..marginBottom = '${insets.bottom}px';
        wrapper.appendChild(element);
        return wrapper;
      }).toJS,
    );
    control.setProperty(
      'onRemove'.toJS,
      ((MmrMap map) => inner.onRemove(map)).toJS,
    );
    return control;
  }

  // --- стиль и его содержимое --------------------------------------------

  /// Меняет стиль карты и возвращает на неё всё, что добавило приложение.
  Future<void> setStyle(VkMapStyle style) async {
    if (style == _appliedStyle) {
      // Тот же стиль карта не перезагружает и о готовности не сообщает,
      // так что ждать было бы нечего.
      return;
    }
    _appliedStyle = style;
    _styleReady = false;
    _reportedMissingImages.clear();
    _map.setStyle(jsValue(VkWebConversions.styleToJs(style)));
    await _whenStyleLoaded();
    if (_disposed) {
      return;
    }
    _styleReady = true;
    _restoreStyleContent();
    _onEvent(const VkStyleAppliedEvent());
  }

  /// Ждёт, пока карта соберёт стиль.
  ///
  /// Ждать одно событие нельзя: `setStyle` с уже применённым стилем ничего
  /// не перезагружает и не шлёт ни `style.load`, ни `styledata`. Поэтому
  /// готовность ещё и опрашивается — иначе карта осталась бы навсегда
  /// «незагруженной», и приложение потеряло бы маркеры, слои и картинки.
  Future<void> _whenStyleLoaded() {
    if (_map.isStyleLoaded()) {
      return Future<void>.value();
    }
    final Completer<void> completer = Completer<void>();

    void finish() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    _map.once(
      'style.load',
      ((MmrMapEvent _) {
        if (!_disposed) {
          finish();
        }
      }).toJS,
    );

    Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      if (completer.isCompleted || _disposed || _map.isStyleLoaded()) {
        timer.cancel();
        if (_disposed) {
          return;
        }
        finish();
      }
    });

    return completer.future;
  }

  void _restoreStyleContent() {
    for (final MapEntry<String, _StyleImage> entry in _images.entries) {
      if (!_map.hasImage(entry.key)) {
        _map.addImage(
          entry.key,
          entry.value.element,
          jsObject(<String, Object?>{'pixelRatio': entry.value.scale}),
        );
      }
    }
    for (final MapEntry<String, String> entry in _sources.entries) {
      _addSourceIfMissing(entry.key, entry.value);
    }
    for (final _StyleLayer layer in _layers) {
      _addLayerIfMissing(layer);
    }
    _syncMarkerLayer();
    if (_userLayersNeeded) {
      _syncUserLocationLayers();
    }
  }

  void _addSourceIfMissing(String sourceId, String geoJson) {
    if (!_styleReady || _map.getSource(sourceId) != null) {
      return;
    }
    _map.addSource(sourceId, jsObject(VkWebConversions.geoJsonSource(geoJson)));
  }

  void _addLayerIfMissing(_StyleLayer layer) {
    if (!_styleReady || _map.getLayer(layer.id) != null) {
      return;
    }
    _map.addLayer(jsObject(layer.json), layer.beforeLayerId);
    if (!layer.visible) {
      _map.setLayoutProperty(layer.id, 'visibility', 'none'.toJS);
    }
  }

  // --- изображения --------------------------------------------------------

  /// Добавляет изображение в стиль карты.
  Future<void> addStyleImage(
    String imageId,
    Uint8List pngBytes, {
    double scale = 1.0,
  }) async {
    final web.Blob blob = web.Blob(
      <JSAny>[pngBytes.toJS].toJS,
      web.BlobPropertyBag(type: 'image/png'),
    );
    final String url = web.URL.createObjectURL(blob);
    final web.HTMLImageElement image = web.HTMLImageElement()..src = url;
    try {
      await image.decode().toDart;
    } finally {
      web.URL.revokeObjectURL(url);
    }
    if (_disposed) {
      return;
    }
    _images[imageId] = _StyleImage(image, scale);
    _reportedMissingImages.remove(imageId);
    if (!_styleReady) {
      return;
    }
    if (_map.hasImage(imageId)) {
      _map.removeImage(imageId);
    }
    _map.addImage(
      imageId,
      image,
      jsObject(<String, Object?>{'pixelRatio': scale}),
    );
  }

  /// Убирает изображение из стиля карты.
  void removeStyleImage(String imageId) {
    _images.remove(imageId);
    if (_styleReady && _map.hasImage(imageId)) {
      _map.removeImage(imageId);
    }
  }

  // --- источники и слои ---------------------------------------------------

  /// Добавляет источник GeoJSON.
  void addGeoJsonSource(String sourceId, String geoJson) {
    _sources[sourceId] = geoJson;
    _addSourceIfMissing(sourceId, geoJson);
  }

  /// Заменяет данные источника GeoJSON.
  void setGeoJsonSourceData(String sourceId, String geoJson) {
    _sources[sourceId] = geoJson;
    if (!_styleReady) {
      return;
    }
    final MmrGeoJsonSource? source = _map.getSource(sourceId);
    if (source == null) {
      _addSourceIfMissing(sourceId, geoJson);
      return;
    }
    source.setData(jsonToJs(geoJson));
  }

  /// Добавляет источник из закодированной ломаной маршрута.
  ///
  /// Ломаная разбирается на Dart-стороне: источники web-SDK принимают
  /// только GeoJSON.
  void addEncodedPolylineSource(String sourceId, String polyline) =>
      addGeoJsonSource(sourceId, VkWebPolyline.toGeoJson(polyline));

  /// Убирает источник.
  void removeSource(String sourceId) {
    _sources.remove(sourceId);
    if (_styleReady && _map.getSource(sourceId) != null) {
      _map.removeSource(sourceId);
    }
  }

  /// Добавляет слой стиля.
  void addLayer(VkStyleLayer layer, {String? beforeLayerId}) {
    final _StyleLayer entry = _StyleLayer(
      VkWebConversions.styleLayer(layer),
      beforeLayerId,
    );
    _layers
      ..removeWhere((_StyleLayer other) => other.id == layer.id)
      ..add(entry);
    _addLayerIfMissing(entry);
  }

  /// Убирает слой стиля.
  void removeLayer(String layerId) {
    _layers.removeWhere((_StyleLayer layer) => layer.id == layerId);
    if (_styleReady && _map.getLayer(layerId) != null) {
      _map.removeLayer(layerId);
    }
  }

  /// Показывает или скрывает слой.
  void setLayerVisibility(String layerId, bool visible) {
    for (final _StyleLayer layer in _layers) {
      if (layer.id == layerId) {
        layer.visible = visible;
      }
    }
    if (_styleReady && _map.getLayer(layerId) != null) {
      _map.setLayoutProperty(
        layerId,
        'visibility',
        (visible ? 'visible' : 'none').toJS,
      );
    }
  }

  // --- маркеры ------------------------------------------------------------

  /// Применяет дельту набора маркеров.
  void updateMarkers(VkMarkerUpdates updates) {
    final Map<String, VkMarker> byId = <String, VkMarker>{
      for (final VkMarker marker in _markers) marker.markerId.value: marker,
    };
    for (final VkMapsObjectId<VkMarker> id in updates.objectIdsToRemove) {
      byId.remove(id.value);
    }
    for (final VkMarker marker in <VkMarker>{
      ...updates.objectsToAdd,
      ...updates.objectsToChange,
    }) {
      byId[marker.markerId.value] = marker;
    }
    _markers = byId.values.toSet();
    _syncMarkerLayer();
  }

  /// Маркеры карты лежат в одном источнике и рисуются одним слоем:
  /// картинка, точка привязки и порядок берутся из свойств объекта.
  void _syncMarkerLayer() {
    if (!_styleReady) {
      return;
    }
    final bool sourceExists =
        _map.getSource(VkWebConversions.markersSourceId) != null;
    if (_markers.isEmpty && !sourceExists) {
      return;
    }
    final String data = jsonEncode(
      VkWebConversions.markersFeatureCollection(_markers),
    );
    if (sourceExists) {
      _map.getSource(VkWebConversions.markersSourceId)!.setData(jsonToJs(data));
    } else {
      _map.addSource(
        VkWebConversions.markersSourceId,
        jsObject(VkWebConversions.geoJsonSource(data)),
      );
    }
    if (_map.getLayer(VkWebConversions.markersLayerId) == null) {
      _map.addLayer(jsObject(VkWebConversions.markersLayer()));
    }
  }

  // --- индикатор пользователя --------------------------------------------

  /// Задаёт положение индикатора пользователя.
  ///
  /// Индикатор рисуется слоями плагина, а не встроенным элементом
  /// управления: координаты приходят от приложения, а `GeolocateControl`
  /// умеет показывать только позицию, полученную браузером.
  Future<void> setUserLocation({
    VkLatLon? coordinates,
    double? bearing,
    double? accuracy,
    bool visible = true,
  }) async {
    _userLocation = coordinates;
    _userBearing = bearing;
    _userAccuracy = accuracy;
    _userVisible = visible;
    _userLayersNeeded = true;
    _syncUserLocationLayers();
    await _followUserLocation();
  }

  void _syncUserLocationLayers() {
    if (!_styleReady) {
      return;
    }
    final VkLatLon? point = _userVisible ? _userLocation : null;
    _upsertSource(
      VkWebConversions.userAccuracySourceId,
      VkWebConversions.userAccuracyGeoJson(point, _userAccuracy),
    );
    _upsertSource(
      VkWebConversions.userLocationSourceId,
      jsonEncode(
        VkWebConversions.userLocationFeatureCollection(
          point,
          bearing: _userBearing,
        ),
      ),
    );

    if (_map.getLayer(VkWebConversions.userAccuracyLayerId) == null) {
      _map.addLayer(jsObject(VkWebConversions.userAccuracyLayer()));
    }
    if (_map.getLayer(VkWebConversions.userLocationLayerId) == null) {
      _map.addLayer(jsObject(VkWebConversions.userLocationLayer()));
    }
  }

  void _upsertSource(String sourceId, String geoJson) {
    final MmrGeoJsonSource? source = _map.getSource(sourceId);
    if (source == null) {
      _map.addSource(
        sourceId,
        jsObject(VkWebConversions.geoJsonSource(geoJson)),
      );
    } else {
      source.setData(jsonToJs(geoJson));
    }
  }

  Future<void> _followUserLocation() async {
    final VkLatLon? location = _userLocation;
    if (location == null || _mode == VkMapMode.free) {
      return;
    }
    final bool withBearing =
        _mode == VkMapMode.followBearingAndLocation && _userBearing != null;
    await moveCamera(
      target: location,
      options: withBearing ? VkCameraOptions(bearing: _userBearing) : null,
      animation: const VkAnimationOptions(
        duration: Duration(milliseconds: 300),
      ),
      followMode: true,
    );
  }

  // --- режим следования ---------------------------------------------------

  /// Текущий режим следования.
  VkMapMode get mode => _mode;

  /// Устанавливает режим следования.
  ///
  /// В JavaScript SDK режимов следования нет: карта сама за индикатором не
  /// ходит. Режим считает плагин — по координатам, которые приложение
  /// присылает в [setUserLocation].
  Future<void> setMode(VkMapMode mode) async {
    if (_mode == mode) {
      return;
    }
    _mode = mode;
    _onEvent(VkMapModeChangedEvent(mode));
    await _followUserLocation();
  }

  // --- завершение ---------------------------------------------------------

  /// Уничтожает карту.
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _completeCamera(VkCameraAnimationResult.cancelled);
    _resizeObserver?.disconnect();
    _resizeObserver = null;
    _map.remove();
  }
}

/// JS-объект из словаря значений Dart.
///
/// Структура переносится через `JSON.parse`, а не поэлементной укладкой:
/// самодельная перекладка однажды уже отправила в карту Dart-объекты вместо
/// объектов JavaScript, и SDK молча выбросил такие данные. Всё, что здесь
/// передаётся, — это данные (стили, слои, GeoJSON, параметры камеры),
/// поэтому JSON им родной формат. Элементы документа сюда не попадают: они
/// кладутся в объект отдельным присваиванием.
JSObject jsObject(Map<String, Object?> values) =>
    jsonToJs(jsonEncode(values)) as JSObject;

/// JS-массив из списка значений Dart.
JSAny jsList(List<Object?> values) => jsonToJs(jsonEncode(values));

/// Значение Dart, переложенное в JavaScript.
JSAny? jsValue(Object? value) => switch (value) {
  null => null,
  final String value => value.toJS,
  final bool value => value.toJS,
  final num value => value.toJS,
  final Map<String, Object?> value => jsObject(value),
  final List<Object?> value => jsList(value),
  _ => jsonToJs(jsonEncode(value)),
};

/// Разобранный JSON, переложенный в JavaScript.
JSAny jsonToJs(String json) => jsonParse(json);
