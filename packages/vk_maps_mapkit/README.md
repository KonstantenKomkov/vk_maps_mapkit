# vk_maps_mapkit

Карта VK Карт во Flutter: виджет `VkMap` поверх нативных SDK для Android и iOS.

> Неофициальный пакет. Ключ доступа к VK Картам пользователь получает
> самостоятельно на [maps.vk.com](https://maps.vk.com/ru/welcome/); условия
> использования определяются договором с VK.

Пакет находится в разработке, публичного релиза ещё нет. План работ —
[`documents/development_plan.md`](../../documents/development_plan.md).

## Состав репозитория

| Пакет | Назначение |
| --- | --- |
| `vk_maps_mapkit` | фасад: виджет и контроллер |
| `vk_maps_mapkit_platform_interface` | контракт и модели |
| `vk_maps_mapkit_android` | реализация для Android |
| `vk_maps_mapkit_ios` | реализация для iOS |
| `vk_maps_api` | REST-клиент на чистом Dart |
