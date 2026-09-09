import 'dart:async';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';
import 'package:web/web.dart' as web;

import 'interop/mmrgl.dart';
import 'map_instance.dart';
import 'sdk_loader.dart';

/// Реализация плагина для web поверх `MMR GL JS` — JavaScript SDK VK Карт.
///
/// Моста в натив здесь нет: вызовы контракта идут прямо в библиотеку на
/// странице, поэтому пакет не наследует общую Pigeon-реализацию, а
/// реализует [VkMapsPlatform] целиком.
final class VkMapsWeb extends VkMapsPlatform {
  /// Создаёт реализацию.
  VkMapsWeb();

  /// Тип platform view, под которым зарегистрирован контейнер карты.
  static const String viewType = 'vk_maps_mapkit/map';

  static bool _viewFactoryRegistered = false;

  /// Контейнеры карт по идентификатору представления.
  ///
  /// Статические: фабрика представлений регистрируется на процесс, и она
  /// же наполняет эту таблицу.
  static final Map<int, web.HTMLElement> _containers = <int, web.HTMLElement>{};

  /// Регистрирует реализацию как текущую платформу.
  ///
  /// Вызывается генерируемым Flutter кодом регистрации плагинов.
  static void registerWith(Registrar registrar) {
    VkMapsPlatform.instance = VkMapsWeb();
  }

  final Map<int, VkWebMapInstance> _maps = <int, VkWebMapInstance>{};
  final Map<int, StreamController<VkMapEvent>> _events =
      <int, StreamController<VkMapEvent>>{};

  bool _initialized = false;

  /// Карта по идентификатору представления.
  ///
  /// Бросает понятную ошибку, если карта ещё не создана или уже удалена:
  /// на web у виджета есть кадр между созданием элемента и созданием
  /// карты.
  VkWebMapInstance _mapOf(int viewId) {
    final VkWebMapInstance? map = _maps[viewId];
    if (map == null) {
      throw StateError(
        'Карта $viewId не создана или уже удалена. Дождитесь onMapCreated.',
      );
    }
    return map;
  }

  StreamController<VkMapEvent> _controllerFor(int viewId) => _events
      .putIfAbsent(viewId, () => StreamController<VkMapEvent>.broadcast());

  /// Закрывает потоки событий всех карт.
  ///
  /// Нужен тестам и на случай выгрузки плагина: обычный путь —
  /// [dispose] для каждой карты.
  Future<void> closeAllEventStreams() async {
    final List<StreamController<VkMapEvent>> controllers = _events.values
        .toList();
    _events.clear();
    for (final StreamController<VkMapEvent> controller in controllers) {
      await controller.close();
    }
  }

  void _emit(int viewId, VkMapEvent event) {
    if (!_controllerFor(viewId).isClosed) {
      _controllerFor(viewId).add(event);
    }
  }

  @override
  Future<void> initialize({
    required String apiKey,
    String? baseUrl,
    String? locale,
  }) async {
    await VkMapsSdkLoader.ensureLoaded();
    mmrgl.accessToken = apiKey;
    if (baseUrl != null) {
      mmrgl.baseApiUrl = baseUrl;
    }
    // Язык подписей на карте web-SDK не задаёт: параметр `locale` в нём —
    // это перевод строк интерфейса, а не язык карты. Значение принимается,
    // но ни на что не влияет (см. docs/platform-matrix.md).
    _initialized = true;
  }

  @override
  Future<bool> isInitialized() async => _initialized && isMmrGlLoaded;

  @override
  Future<void> initializeView(
    int viewId,
    VkMapInitialConfiguration configuration,
  ) async {
    if (!isMmrGlLoaded) {
      throw StateError(
        'JavaScript SDK VK Карт не загружен. Вызовите VkMaps.init(apiKey: …) '
        'до показа виджета VkMap.',
      );
    }
    final web.HTMLElement? container = _containers[viewId];
    if (container == null) {
      throw StateError('Контейнер карты $viewId не создан.');
    }
    _maps[viewId] = VkWebMapInstance(
      viewId: viewId,
      container: container,
      configuration: configuration,
      onEvent: (VkMapEvent event) => _emit(viewId, event),
    );
  }

  @override
  Future<void> updateConfiguration(
    int viewId,
    VkMapConfiguration configuration,
  ) async {
    if (configuration.isEmpty) {
      return;
    }
    await _mapOf(viewId).updateConfiguration(configuration);
  }

  @override
  Future<void> updateMarkers(int viewId, VkMarkerUpdates updates) async {
    if (updates.isEmpty) {
      return;
    }
    _mapOf(viewId).updateMarkers(updates);
  }

  @override
  Future<VkCameraAnimationResult> moveCamera(
    int viewId, {
    VkLatLon? target,
    VkCameraOptions? options,
    VkAnimationOptions? animation,
  }) => _mapOf(
    viewId,
  ).moveCamera(target: target, options: options, animation: animation);

  @override
  Future<VkCameraAnimationResult> fitBounds(
    int viewId,
    VkLatLonBounds bounds, {
    VkEdgeInsets padding = VkEdgeInsets.zero,
    VkAnimationOptions? animation,
  }) =>
      _mapOf(viewId).fitBounds(bounds, padding: padding, animation: animation);

  @override
  Future<VkCameraPosition> getCameraPosition(int viewId) async =>
      _mapOf(viewId).cameraPosition();

  @override
  Future<VkLatLonBounds> getVisibleBounds(int viewId) async =>
      _mapOf(viewId).visibleBounds();

  @override
  Future<VkLatLon?> coordinateForScreenPoint(
    int viewId,
    VkScreenPoint point,
  ) async => _mapOf(viewId).coordinateForScreenPoint(point);

  @override
  Future<VkScreenPoint?> screenPointForCoordinate(
    int viewId,
    VkLatLon coordinate,
  ) async => _mapOf(viewId).screenPointForCoordinate(coordinate);

  @override
  Future<VkMapMode> getMode(int viewId) async => _mapOf(viewId).mode;

  @override
  Future<void> setMode(int viewId, VkMapMode mode) =>
      _mapOf(viewId).setMode(mode);

  @override
  Future<void> setUserLocation(
    int viewId, {
    VkLatLon? coordinates,
    double? bearing,
    double? accuracy,
    bool visible = true,
  }) => _mapOf(viewId).setUserLocation(
    coordinates: coordinates,
    bearing: bearing,
    accuracy: accuracy,
    visible: visible,
  );

  @override
  Future<void> addStyleImage(
    int viewId,
    String imageId,
    Uint8List pngBytes, {
    double scale = 1.0,
  }) => _mapOf(viewId).addStyleImage(imageId, pngBytes, scale: scale);

  @override
  Future<void> removeStyleImage(int viewId, String imageId) async =>
      _mapOf(viewId).removeStyleImage(imageId);

  @override
  Future<void> addGeoJsonSource(
    int viewId,
    String sourceId,
    String geoJson,
  ) async => _mapOf(viewId).addGeoJsonSource(sourceId, geoJson);

  @override
  Future<void> setGeoJsonSourceData(
    int viewId,
    String sourceId,
    String geoJson,
  ) async => _mapOf(viewId).setGeoJsonSourceData(sourceId, geoJson);

  @override
  Future<void> addEncodedPolylineSource(
    int viewId,
    String sourceId,
    String polyline,
  ) async => _mapOf(viewId).addEncodedPolylineSource(sourceId, polyline);

  @override
  Future<void> removeSource(int viewId, String sourceId) async =>
      _mapOf(viewId).removeSource(sourceId);

  @override
  Future<void> addLayer(
    int viewId,
    VkStyleLayer layer, {
    String? beforeLayerId,
  }) async => _mapOf(viewId).addLayer(layer, beforeLayerId: beforeLayerId);

  @override
  Future<void> removeLayer(int viewId, String layerId) async =>
      _mapOf(viewId).removeLayer(layerId);

  @override
  Future<void> setLayerVisibility(
    int viewId,
    String layerId,
    bool visible,
  ) async => _mapOf(viewId).setLayerVisibility(layerId, visible);

  @override
  Future<void> dispose(int viewId) async {
    _maps.remove(viewId)?.dispose();
    _containers.remove(viewId);
    await _events.remove(viewId)?.close();
  }

  @override
  Stream<VkMapEvent> events(int viewId) => _controllerFor(viewId).stream;

  @override
  Widget buildView({
    required VkMapInitialConfiguration configuration,
    required void Function(int viewId) onPlatformViewCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers =
        const <Factory<OneSequenceGestureRecognizer>>{},
    PlatformViewHitTestBehavior hitTestBehavior =
        PlatformViewHitTestBehavior.opaque,
    TextDirection? layoutDirection,
  }) {
    _registerViewFactory();
    return HtmlElementView(
      viewType: viewType,
      onPlatformViewCreated: (int viewId) async {
        // Параметры создания идут отдельным вызовом — тем же, что на
        // мобильных платформах: контракт остаётся один на всё.
        await initializeView(viewId, configuration);
        onPlatformViewCreated(viewId);
      },
    );
  }

  void _registerViewFactory() {
    if (_viewFactoryRegistered) {
      return;
    }
    _viewFactoryRegistered = true;
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final web.HTMLDivElement element = web.HTMLDivElement();
      element.style
        ..width = '100%'
        ..height = '100%'
        // Карта рисует свои элементы управления абсолютно, и без этого они
        // считали бы началом координат угол страницы, а не угол карты.
        ..position = 'relative'
        ..overflow = 'hidden';
      _containers[viewId] = element;
      return element;
    });
  }
}
