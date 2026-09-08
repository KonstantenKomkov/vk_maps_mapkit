/// Общий контракт между фасадом `vk_maps_mapkit` и нативными реализациями
/// VK Карт для Android и iOS.
///
/// Пакет не содержит платформенного кода: только модели, события и
/// абстракцию `VkMapsPlatform`, которую реализуют платформенные пакеты.
library;

export 'src/events/map_event.dart';
export 'src/pigeon/pigeon_vk_maps_platform.dart';
export 'src/platform_interface/vk_maps_platform.dart';
export 'src/types/types.dart';
