import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';

/// Реализация плагина для iOS.
///
/// Логика моста общая с Android и живёт в [PigeonVkMapsPlatform]; здесь
/// добавляется только нативное представление.
final class VkMapsIos extends PigeonVkMapsPlatform {
  /// Тип нативного представления, зарегистрированный в Swift-коде.
  static const String viewType = 'vk_maps_mapkit/map';

  /// Регистрирует реализацию как текущую платформу.
  ///
  /// Вызывается генерируемым Flutter кодом регистрации плагинов.
  static void registerWith() {
    VkMapsPlatform.instance = VkMapsIos();
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
  }) => UiKitView(
    viewType: viewType,
    onPlatformViewCreated: (int viewId) async {
      // Параметры создания идут отдельным типизированным вызовом, а не
      // через кодек представления: контракт остаётся один на всё.
      await initializeView(viewId, configuration);
      onPlatformViewCreated(viewId);
    },
    gestureRecognizers: gestureRecognizers,
    hitTestBehavior: hitTestBehavior,
    layoutDirection: layoutDirection,
  );
}
