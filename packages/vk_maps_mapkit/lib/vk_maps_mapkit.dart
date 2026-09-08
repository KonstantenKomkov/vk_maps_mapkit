/// Карта VK Карт во Flutter: виджет [VkMap] поверх нативных SDK.
///
/// Быстрый старт:
///
/// ```dart
/// await VkMaps.init(apiKey: 'ключ');
///
/// VkMap(
///   initialCameraPosition: VkCameraPosition(
///     target: VkLatLon(55.796932, 37.537849),
///     zoom: 12,
///   ),
///   onMapCreated: (VkMapController controller) => _controller = controller,
/// );
/// ```
library;

export 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart'
    show
        VkAnimationDurationMode,
        VkAnimationEasing,
        VkAnimationOptions,
        VkCameraAnimationResult,
        VkCameraMoveEvent,
        VkCameraMovingPhase,
        VkCameraMovingReason,
        VkCameraOptions,
        VkCameraPosition,
        VkEdgeInsets,
        VkFeaturesSelectionMode,
        VkGeoJson,
        VkJsonMapStyle,
        VkLatLon,
        VkLatLonBounds,
        VkLogoAlignment,
        VkMapErrorEvent,
        VkMapEvent,
        VkMapLowMemoryEvent,
        VkMapMode,
        VkMapModeChangedEvent,
        VkMapShownEvent,
        VkMapStyle,
        VkMapTapEvent,
        VkMapsObjectId,
        VkMarker,
        VkMarkerAlignment,
        VkMarkerId,
        VkMarkerTapEvent,
        VkPlatformViewType,
        VkPredefinedMapStyle,
        VkPredefinedStyle,
        VkScreenPoint,
        VkStyleAppliedEvent,
        VkStyleLayer,
        VkUrlMapStyle;

export 'src/clustering.dart';
export 'src/vk_map.dart';
export 'src/vk_map_controller.dart';
export 'src/vk_maps.dart';
