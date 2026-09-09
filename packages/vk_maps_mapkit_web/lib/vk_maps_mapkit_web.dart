/// Web-реализация плагина `vk_maps_mapkit` поверх `MMR GL JS` —
/// JavaScript SDK VK Карт.
///
/// Пакет подключается автоматически через `default_package` фасада —
/// напрямую его импортировать нужно только затем, чтобы задать адрес или
/// версию библиотеки в [VkMapsSdkLoader].
library;

export 'src/sdk_loader.dart' show VkMapsSdkLoader;
export 'src/vk_maps_web.dart' show VkMapsWeb;
