/// Общий контракт между фасадом `vk_maps_mapkit` и нативными реализациями
/// VK Карт для Android и iOS.
///
/// Пакет не содержит платформенного кода: только модели, события и
/// абстракцию `VkMapsPlatform`, которую реализуют платформенные пакеты.
library;

export 'src/events/map_event.dart';
export 'src/types/types.dart';
