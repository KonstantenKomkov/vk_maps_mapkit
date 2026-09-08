import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';

/// Точка входа плагина: разовая настройка SDK VK Карт.
abstract final class VkMaps {
  /// Настраивает SDK ключом доступа.
  ///
  /// Вызывается один раз до появления первой карты, обычно в `main`.
  /// Повторный вызов безопасен: SDK не переинициализируется.
  ///
  /// [apiKey] — ключ доступа VK Карт, [baseUrl] — адрес сервера (нужен для
  /// демонстрационного сервера), [locale] — язык подписей на карте.
  static Future<void> init({
    required String apiKey,
    String? baseUrl,
    String? locale,
  }) => VkMapsPlatform.instance.initialize(
    apiKey: apiKey,
    baseUrl: baseUrl,
    locale: locale,
  );

  /// Настроен ли SDK.
  static Future<bool> get isInitialized =>
      VkMapsPlatform.instance.isInitialized();
}
