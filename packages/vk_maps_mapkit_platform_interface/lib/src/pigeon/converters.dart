import '../../vk_maps_mapkit_platform_interface.dart';
import '../messages.g.dart';

/// Перевод моделей Dart-API в сообщения моста и обратно.
///
/// Слой держится отдельно, чтобы публичные модели не зависели от
/// сгенерированного кода, а сгенерированный код не протекал в приложение.
extension VkLatLonMessage on VkLatLon {
  /// Сообщение моста для координаты.
  PlatformLatLon toMessage() =>
      PlatformLatLon(latitude: latitude, longitude: longitude);
}

/// Координата из сообщения моста.
VkLatLon latLonFromMessage(PlatformLatLon message) =>
    VkLatLon(message.latitude, message.longitude);

/// Границы из сообщения моста.
VkLatLonBounds boundsFromMessage(PlatformLatLonBounds message) =>
    VkLatLonBounds(
      southwest: latLonFromMessage(message.southwest),
      northeast: latLonFromMessage(message.northeast),
    );

/// Положение камеры из сообщения моста.
VkCameraPosition cameraPositionFromMessage(PlatformCameraPosition message) =>
    VkCameraPosition(
      target: latLonFromMessage(message.target),
      zoom: message.zoom,
      bearing: message.bearing,
      pitch: message.pitch,
    );

/// Отступы для моста.
extension VkEdgeInsetsMessage on VkEdgeInsets {
  /// Сообщение моста для отступов.
  PlatformEdgeInsets toMessage() =>
      PlatformEdgeInsets(left: left, top: top, right: right, bottom: bottom);
}

/// Экранная точка для моста.
extension VkScreenPointMessage on VkScreenPoint {
  /// Сообщение моста для экранной точки.
  PlatformScreenPoint toMessage() => PlatformScreenPoint(x: x, y: y);
}

/// Экранная точка из сообщения моста.
VkScreenPoint screenPointFromMessage(PlatformScreenPoint message) =>
    VkScreenPoint(message.x, message.y);

/// Положение камеры для моста.
extension VkCameraPositionMessage on VkCameraPosition {
  /// Сообщение моста для положения камеры.
  PlatformCameraPosition toMessage() => PlatformCameraPosition(
    target: target.toMessage(),
    zoom: zoom,
    bearing: bearing,
    pitch: pitch,
  );
}

/// Изменения камеры для моста.
extension VkCameraOptionsMessage on VkCameraOptions {
  /// Сообщение моста для изменений камеры.
  PlatformCameraOptions toMessage() => PlatformCameraOptions(
    zoom: zoom,
    bearing: bearing,
    pitch: pitch,
    padding: padding?.toMessage(),
  );
}

/// Параметры анимации для моста.
extension VkAnimationOptionsMessage on VkAnimationOptions {
  /// Сообщение моста для параметров анимации.
  PlatformAnimationOptions toMessage() => PlatformAnimationOptions(
    durationMillis: duration.inMilliseconds,
    easing: switch (easing) {
      VkAnimationEasing.linear => PlatformAnimationEasing.linear,
      VkAnimationEasing.easeIn => PlatformAnimationEasing.easeIn,
      VkAnimationEasing.easeOut => PlatformAnimationEasing.easeOut,
      VkAnimationEasing.easeInOut => PlatformAnimationEasing.easeInOut,
    },
    durationMode: switch (durationMode) {
      VkAnimationDurationMode.exact => PlatformAnimationDurationMode.exact,
      VkAnimationDurationMode.atMost => PlatformAnimationDurationMode.atMost,
    },
  );
}

/// Стиль карты для моста.
extension VkMapStyleMessage on VkMapStyle {
  /// Сообщение моста для стиля.
  PlatformStyle toMessage() => switch (this) {
    VkPredefinedMapStyle(:final VkPredefinedStyle style) => PlatformStyle(
      kind: PlatformStyleKind.predefined,
      predefined: switch (style) {
        VkPredefinedStyle.main => PlatformPredefinedStyle.main,
        VkPredefinedStyle.dark => PlatformPredefinedStyle.dark,
        VkPredefinedStyle.grayLight => PlatformPredefinedStyle.grayLight,
        VkPredefinedStyle.simple => PlatformPredefinedStyle.simple,
        VkPredefinedStyle.simpleDark => PlatformPredefinedStyle.simpleDark,
        VkPredefinedStyle.navigationMain =>
          PlatformPredefinedStyle.navigationMain,
        VkPredefinedStyle.navigationDark =>
          PlatformPredefinedStyle.navigationDark,
      },
    ),
    VkJsonMapStyle(:final String json) => PlatformStyle(
      kind: PlatformStyleKind.json,
      json: json,
    ),
    VkUrlMapStyle(:final Uri url) => PlatformStyle(
      kind: PlatformStyleKind.url,
      url: url.toString(),
    ),
  };
}

/// Режим следования для моста.
PlatformMapMode mapModeToMessage(VkMapMode mode) => switch (mode) {
  VkMapMode.free => PlatformMapMode.free,
  VkMapMode.followLocation => PlatformMapMode.followLocation,
  VkMapMode.followBearingAndLocation =>
    PlatformMapMode.followBearingAndLocation,
};

/// Режим следования из сообщения моста.
VkMapMode mapModeFromMessage(PlatformMapMode mode) => switch (mode) {
  PlatformMapMode.free => VkMapMode.free,
  PlatformMapMode.followLocation => VkMapMode.followLocation,
  PlatformMapMode.followBearingAndLocation =>
    VkMapMode.followBearingAndLocation,
};

/// Настройки карты для моста.
extension VkMapConfigurationMessage on VkMapConfiguration {
  /// Сообщение моста для настроек карты.
  PlatformMapConfiguration toMessage() => PlatformMapConfiguration(
    style: style?.toMessage(),
    compassEnabled: compassEnabled,
    zoomButtonsEnabled: zoomButtonsEnabled,
    currentLocationButtonEnabled: currentLocationButtonEnabled,
    scrollGesturesEnabled: scrollGesturesEnabled,
    zoomGesturesEnabled: zoomGesturesEnabled,
    rotateGesturesEnabled: rotateGesturesEnabled,
    logoAlignment: switch (logoAlignment) {
      null => null,
      VkLogoAlignment.topLeft => PlatformLogoAlignment.topLeft,
      VkLogoAlignment.topRight => PlatformLogoAlignment.topRight,
      VkLogoAlignment.bottomLeft => PlatformLogoAlignment.bottomLeft,
      VkLogoAlignment.bottomRight => PlatformLogoAlignment.bottomRight,
    },
    logoInsets: logoInsets?.toMessage(),
    logoIgnoresSafeArea: logoIgnoresSafeArea,
    padding: padding?.toMessage(),
    featuresSelectionMode: switch (featuresSelectionMode) {
      null => null,
      VkFeaturesSelectionMode.none => PlatformFeaturesSelectionMode.none,
      VkFeaturesSelectionMode.handleEvents =>
        PlatformFeaturesSelectionMode.handleEvents,
      VkFeaturesSelectionMode.drawSelection =>
        PlatformFeaturesSelectionMode.drawSelection,
      VkFeaturesSelectionMode.all => PlatformFeaturesSelectionMode.all,
    },
    minZoom: minZoom,
    maxZoom: maxZoom,
  );
}

/// Начальные параметры карты для моста.
extension VkMapInitialConfigurationMessage on VkMapInitialConfiguration {
  /// Сообщение моста для начальных параметров.
  PlatformMapCreationParams toMessage() => PlatformMapCreationParams(
    initialCameraPosition: initialCameraPosition.toMessage(),
    configuration: configuration.toMessage(),
    platformViewType: switch (platformViewType) {
      VkPlatformViewType.hybrid => PlatformViewType.hybrid,
      VkPlatformViewType.virtual => PlatformViewType.virtual,
      VkPlatformViewType.textureHybrid => PlatformViewType.textureHybrid,
      VkPlatformViewType.compat => PlatformViewType.compat,
    },
  );
}

/// Маркер для моста.
extension VkMarkerMessage on VkMarker {
  /// Сообщение моста для маркера.
  PlatformMarker toMessage() => PlatformMarker(
    markerId: markerId.value,
    position: position.toMessage(),
    imageId: imageId,
    alignment: switch (alignment) {
      VkMarkerAlignment.center => PlatformMarkerAlignment.center,
      VkMarkerAlignment.top => PlatformMarkerAlignment.top,
      VkMarkerAlignment.bottom => PlatformMarkerAlignment.bottom,
      VkMarkerAlignment.left => PlatformMarkerAlignment.left,
      VkMarkerAlignment.right => PlatformMarkerAlignment.right,
      VkMarkerAlignment.topLeft => PlatformMarkerAlignment.topLeft,
      VkMarkerAlignment.topRight => PlatformMarkerAlignment.topRight,
      VkMarkerAlignment.bottomLeft => PlatformMarkerAlignment.bottomLeft,
      VkMarkerAlignment.bottomRight => PlatformMarkerAlignment.bottomRight,
    },
    zIndex: zIndex,
    visible: visible,
  );
}

/// Дельта маркеров для моста.
extension VkMarkerUpdatesMessage on VkMarkerUpdates {
  /// Сообщение моста для дельты маркеров.
  PlatformMarkerUpdates toMessage() => PlatformMarkerUpdates(
    toAdd: objectsToAdd.map((VkMarker m) => m.toMessage()).toList(),
    toChange: objectsToChange.map((VkMarker m) => m.toMessage()).toList(),
    idsToRemove: objectIdsToRemove.map((VkMarkerId id) => id.value).toList(),
  );
}

/// Результат перемещения камеры из сообщения моста.
VkCameraAnimationResult cameraResultFromMessage(
  PlatformCameraAnimationResult result,
) => switch (result) {
  PlatformCameraAnimationResult.finished => VkCameraAnimationResult.finished,
  PlatformCameraAnimationResult.cancelled => VkCameraAnimationResult.cancelled,
};

/// Событие карты из сообщения моста.
///
/// Возвращает `null`, если платформа прислала событие, набор полей которого
/// не соответствует заявленному типу: терять поток событий из-за одного
/// битого сообщения нельзя.
VkMapEvent? mapEventFromMessage(PlatformMapEvent message) {
  switch (message.type) {
    case PlatformMapEventType.mapShown:
      return const VkMapShownEvent();
    case PlatformMapEventType.tap:
    case PlatformMapEventType.longTap:
      final PlatformLatLon? position = message.position;
      final PlatformScreenPoint? point = message.screenPoint;
      if (position == null || point == null) {
        return null;
      }
      return VkMapTapEvent(
        position: latLonFromMessage(position),
        screenPoint: screenPointFromMessage(point),
        isLongTap: message.type == PlatformMapEventType.longTap,
      );
    case PlatformMapEventType.markerTap:
      final String? markerId = message.markerId;
      final PlatformLatLon? position = message.position;
      if (markerId == null || position == null) {
        return null;
      }
      return VkMarkerTapEvent(
        markerId: VkMarkerId(markerId),
        position: latLonFromMessage(position),
      );
    case PlatformMapEventType.cameraMove:
      final PlatformCameraPosition? position = message.cameraPosition;
      if (position == null) {
        return null;
      }
      return VkCameraMoveEvent(
        position: cameraPositionFromMessage(position),
        reason: switch (message.cameraMovingReason) {
          PlatformCameraMovingReason.gesture => VkCameraMovingReason.gesture,
          PlatformCameraMovingReason.api => VkCameraMovingReason.api,
          PlatformCameraMovingReason.followMode =>
            VkCameraMovingReason.followMode,
          _ => VkCameraMovingReason.unknown,
        },
        phase: switch (message.cameraMovingPhase) {
          PlatformCameraMovingPhase.started => VkCameraMovingPhase.started,
          PlatformCameraMovingPhase.singleCompleted =>
            VkCameraMovingPhase.singleCompleted,
          PlatformCameraMovingPhase.allCompleted =>
            VkCameraMovingPhase.allCompleted,
          PlatformCameraMovingPhase.cancelled => VkCameraMovingPhase.cancelled,
          _ => VkCameraMovingPhase.moving,
        },
      );
    case PlatformMapEventType.styleApplied:
      return const VkStyleAppliedEvent();
    case PlatformMapEventType.modeChanged:
      final PlatformMapMode? mode = message.mode;
      if (mode == null) {
        return null;
      }
      return VkMapModeChangedEvent(mapModeFromMessage(mode));
    case PlatformMapEventType.lowMemory:
      return const VkMapLowMemoryEvent();
    case PlatformMapEventType.error:
      return VkMapErrorEvent(
        code: message.errorCode ?? 'unknown',
        message: message.errorMessage ?? '',
      );
  }
}
