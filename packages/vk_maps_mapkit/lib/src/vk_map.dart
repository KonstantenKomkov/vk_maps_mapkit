import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';

import 'vk_map_controller.dart';

/// Обработчик события создания карты.
typedef VkMapCreatedCallback = void Function(VkMapController controller);

/// Обработчик касания карты.
typedef VkMapTapCallback = void Function(VkLatLon position);

/// Обработчик касания маркера.
typedef VkMarkerTapCallback = void Function(VkMarkerId markerId);

/// Обработчик перемещения камеры.
typedef VkCameraMoveCallback = void Function(VkCameraPosition position);

/// Обработчик ошибки карты.
typedef VkMapErrorCallback = void Function(String code, String message);

/// Карта VK Карт.
///
/// Объекты на карте задаются наборами ([markers]): при изменении набора в
/// нативный SDK уходит только разница, а не весь набор заново.
///
/// Логотип VK скрыть нельзя — его можно только сдвинуть ([logoAlignment],
/// [logoInsets]).
class VkMap extends StatefulWidget {
  /// Создаёт виджет карты.
  const VkMap({
    super.key,
    required this.initialCameraPosition,
    this.onMapCreated,
    this.style,
    this.markers = const <VkMarker>{},
    this.compassEnabled = true,
    this.zoomButtonsEnabled = false,
    this.currentLocationButtonEnabled = false,
    this.scrollGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.rotateGesturesEnabled = true,
    this.padding = VkEdgeInsets.zero,
    this.logoAlignment = VkLogoAlignment.bottomRight,
    this.logoInsets = VkEdgeInsets.zero,
    this.logoIgnoresSafeArea = false,
    this.featuresSelectionMode = VkFeaturesSelectionMode.none,
    this.minZoom,
    this.maxZoom,
    this.platformViewType = VkPlatformViewType.compat,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.hitTestBehavior = PlatformViewHitTestBehavior.opaque,
    this.layoutDirection,
    this.onTap,
    this.onLongTap,
    this.onMarkerTap,
    this.onCameraMove,
    this.onCameraIdle,
    this.onStyleApplied,
    this.onError,
  });

  /// Положение камеры при первом показе карты.
  final VkCameraPosition initialCameraPosition;

  /// Вызывается, когда карта создана и с ней можно работать.
  final VkMapCreatedCallback? onMapCreated;

  /// Стиль карты. `null` — оставить стиль по умолчанию из SDK.
  final VkMapStyle? style;

  /// Маркеры на карте.
  final Set<VkMarker> markers;

  /// Показывать ли компас.
  final bool compassEnabled;

  /// Показывать ли кнопки масштабирования.
  final bool zoomButtonsEnabled;

  /// Показывать ли кнопку «текущая позиция».
  final bool currentLocationButtonEnabled;

  /// Разрешено ли двигать карту жестами.
  final bool scrollGesturesEnabled;

  /// Разрешено ли масштабировать жестами.
  final bool zoomGesturesEnabled;

  /// Разрешено ли вращать карту жестами.
  final bool rotateGesturesEnabled;

  /// Отступы камеры: полезны, когда часть карты перекрыта интерфейсом.
  final VkEdgeInsets padding;

  /// Угол, в котором показывается логотип VK.
  final VkLogoAlignment logoAlignment;

  /// Отступы логотипа от края карты.
  final VkEdgeInsets logoInsets;

  /// Игнорировать ли безопасную область при размещении логотипа.
  final bool logoIgnoresSafeArea;

  /// Как карта реагирует на касание объектов стиля.
  final VkFeaturesSelectionMode featuresSelectionMode;

  /// Минимальный уровень масштабирования.
  final double? minZoom;

  /// Максимальный уровень масштабирования.
  final double? maxZoom;

  /// Способ встраивания нативной карты (учитывается только на Android).
  final VkPlatformViewType platformViewType;

  /// Распознаватели жестов, которым карта уступает касания.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// Как карта участвует в hit-тестировании.
  final PlatformViewHitTestBehavior hitTestBehavior;

  /// Направление раскладки нативного представления.
  final TextDirection? layoutDirection;

  /// Касание карты.
  final VkMapTapCallback? onTap;

  /// Долгое касание карты.
  final VkMapTapCallback? onLongTap;

  /// Касание маркера.
  final VkMarkerTapCallback? onMarkerTap;

  /// Перемещение камеры.
  final VkCameraMoveCallback? onCameraMove;

  /// Камера остановилась.
  final VkCameraMoveCallback? onCameraIdle;

  /// Стиль применён.
  final VoidCallback? onStyleApplied;

  /// Ошибка карты.
  final VkMapErrorCallback? onError;

  /// Настройки, которые можно менять после создания карты.
  VkMapConfiguration get configuration => VkMapConfiguration(
    style: style,
    compassEnabled: compassEnabled,
    zoomButtonsEnabled: zoomButtonsEnabled,
    currentLocationButtonEnabled: currentLocationButtonEnabled,
    scrollGesturesEnabled: scrollGesturesEnabled,
    zoomGesturesEnabled: zoomGesturesEnabled,
    rotateGesturesEnabled: rotateGesturesEnabled,
    logoAlignment: logoAlignment,
    logoInsets: logoInsets,
    logoIgnoresSafeArea: logoIgnoresSafeArea,
    padding: padding,
    featuresSelectionMode: featuresSelectionMode,
    minZoom: minZoom,
    maxZoom: maxZoom,
  );

  @override
  State<VkMap> createState() => _VkMapState();
}

class _VkMapState extends State<VkMap> {
  VkMapController? _controller;
  StreamSubscription<VkMapEvent>? _eventsSubscription;
  late VkMapConfiguration _appliedConfiguration;
  Set<VkMarker> _appliedMarkers = const <VkMarker>{};

  @override
  void initState() {
    super.initState();
    // Снимок настроек берётся сразу: ленивая инициализация прочитала бы уже
    // обновлённый виджет, и первая же дельта оказалась бы пустой.
    _appliedConfiguration = widget.configuration;
  }

  @override
  Widget build(BuildContext context) => VkMapsPlatform.instance.buildView(
    configuration: VkMapInitialConfiguration(
      initialCameraPosition: widget.initialCameraPosition,
      configuration: widget.configuration,
      platformViewType: widget.platformViewType,
    ),
    onPlatformViewCreated: _onPlatformViewCreated,
    gestureRecognizers: widget.gestureRecognizers,
    hitTestBehavior: widget.hitTestBehavior,
    layoutDirection: widget.layoutDirection,
  );

  @override
  void didUpdateWidget(VkMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_syncWithWidget());
  }

  @override
  void dispose() {
    unawaited(_eventsSubscription?.cancel());
    final VkMapController? controller = _controller;
    _controller = null;
    if (controller != null) {
      unawaited(VkMapsPlatform.instance.dispose(controller.viewId));
    }
    super.dispose();
  }

  void _onPlatformViewCreated(int viewId) {
    final VkMapController controller = VkMapController(viewId);
    _controller = controller;
    _appliedMarkers = widget.markers;
    _eventsSubscription = controller.events.listen(_handleEvent);
    // Начальные маркеры кладутся сразу: в параметрах создания карты их нет.
    if (widget.markers.isNotEmpty) {
      unawaited(
        VkMapsPlatform.instance.updateMarkers(
          viewId,
          VkMarkerUpdates.from(const <VkMarker>{}, widget.markers),
        ),
      );
    }
    widget.onMapCreated?.call(controller);
  }

  Future<void> _syncWithWidget() async {
    final VkMapController? controller = _controller;
    if (controller == null) {
      return;
    }

    final VkMapConfiguration configuration = widget.configuration;
    final VkMapConfiguration diff = configuration.diffFrom(
      _appliedConfiguration,
    );
    _appliedConfiguration = configuration;
    if (diff.isNotEmpty) {
      await VkMapsPlatform.instance.updateConfiguration(
        controller.viewId,
        diff,
      );
    }

    final VkMarkerUpdates markerUpdates = VkMarkerUpdates.from(
      _appliedMarkers,
      widget.markers,
    );
    _appliedMarkers = widget.markers;
    if (markerUpdates.isNotEmpty) {
      await VkMapsPlatform.instance.updateMarkers(
        controller.viewId,
        markerUpdates,
      );
    }
  }

  void _handleEvent(VkMapEvent event) {
    switch (event) {
      case VkMapTapEvent(:final VkLatLon position, isLongTap: false):
        widget.onTap?.call(position);
      case VkMapTapEvent(:final VkLatLon position, isLongTap: true):
        widget.onLongTap?.call(position);
      case VkMarkerTapEvent(:final VkMarkerId markerId):
        widget.onMarkerTap?.call(markerId);
      case VkCameraMoveEvent(
        :final VkCameraPosition position,
        :final VkCameraMovingPhase phase,
      ):
        widget.onCameraMove?.call(position);
        if (phase == VkCameraMovingPhase.allCompleted ||
            phase == VkCameraMovingPhase.cancelled) {
          widget.onCameraIdle?.call(position);
        }
      case VkStyleAppliedEvent():
        widget.onStyleApplied?.call();
      case VkMapErrorEvent(:final String code, :final String message):
        widget.onError?.call(code, message);
      case VkMapShownEvent():
      case VkMapModeChangedEvent():
      case VkMapLowMemoryEvent():
        break;
    }
  }
}
