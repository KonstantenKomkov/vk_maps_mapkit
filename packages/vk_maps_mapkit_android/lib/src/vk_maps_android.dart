import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';

/// Реализация плагина для Android.
///
/// Логика моста общая с iOS и живёт в [PigeonVkMapsPlatform]; здесь
/// добавляется только нативное представление и выбор режима композиции.
final class VkMapsAndroid extends PigeonVkMapsPlatform {
  /// Тип нативного представления, зарегистрированный в Kotlin-коде.
  static const String viewType = 'vk_maps_mapkit/map';

  /// Регистрирует реализацию как текущую платформу.
  ///
  /// Вызывается генерируемым Flutter кодом регистрации плагинов.
  static void registerWith() {
    VkMapsPlatform.instance = VkMapsAndroid();
  }

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
    void onCreated(int viewId) {
      // Параметры создания идут отдельным типизированным вызовом, а не
      // через кодек представления: контракт остаётся один на всё.
      initializeView(viewId, configuration).then((_) {
        onPlatformViewCreated(viewId);
      });
    }

    switch (configuration.platformViewType) {
      case VkPlatformViewType.virtual:
        return AndroidView(
          viewType: viewType,
          onPlatformViewCreated: onCreated,
          gestureRecognizers: gestureRecognizers,
          hitTestBehavior: hitTestBehavior,
          layoutDirection: layoutDirection ?? TextDirection.ltr,
        );
      case VkPlatformViewType.hybrid:
      case VkPlatformViewType.textureHybrid:
      case VkPlatformViewType.compat:
        return PlatformViewLink(
          viewType: viewType,
          surfaceFactory:
              (BuildContext context, PlatformViewController controller) {
                return AndroidViewSurface(
                  controller: controller as AndroidViewController,
                  gestureRecognizers: gestureRecognizers,
                  hitTestBehavior: hitTestBehavior,
                );
              },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            final AndroidViewController controller = _createController(
              params,
              configuration.platformViewType,
              layoutDirection,
            );
            controller
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..addOnPlatformViewCreatedListener(onCreated)
              ..create();
            return controller;
          },
        );
    }
  }

  AndroidViewController _createController(
    PlatformViewCreationParams params,
    VkPlatformViewType type,
    TextDirection? layoutDirection,
  ) {
    final TextDirection direction = layoutDirection ?? TextDirection.ltr;
    switch (type) {
      case VkPlatformViewType.hybrid:
        return PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: direction,
        );
      case VkPlatformViewType.textureHybrid:
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: direction,
        );
      case VkPlatformViewType.compat:
      case VkPlatformViewType.virtual:
        return PlatformViewsService.initAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: direction,
        );
    }
  }
}
