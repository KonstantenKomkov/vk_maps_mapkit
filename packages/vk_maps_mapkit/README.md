# vk_maps_mapkit

Карта VK Карт во Flutter: виджет `VkMap` поверх нативных SDK для Android и iOS.

> Неофициальный пакет. Ключ доступа выдаёт VK Карты — получить его можно на
> [maps.vk.com](https://maps.vk.com/ru/welcome/); условия использования
> определяются договором с VK.

**Статус:** в разработке. Android собрать нельзя, пока вендор не сообщит
адрес выкладки SDK — см. [состояние проекта](../../docs/status.md).

## Быстрый старт

```dart
import 'package:vk_maps_mapkit/vk_maps_mapkit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VkMaps.init(apiKey: 'ваш ключ', locale: 'ru');
  runApp(const MyApp());
}

VkMap(
  initialCameraPosition: VkCameraPosition(
    target: VkLatLon(55.796932, 37.537849),
    zoom: 13,
  ),
  markers: <VkMarker>{
    VkMarker(
      markerId: const VkMarkerId('office'),
      position: VkLatLon(55.796932, 37.537849),
      imageId: 'pin',
    ),
  },
  onMapCreated: (VkMapController controller) => _controller = controller,
  onTap: (VkLatLon position) => debugPrint('Касание: $position'),
);
```

Объекты задаются наборами: при изменении набора в нативный SDK уходит только
разница, а не весь набор заново.

## Подключение

### iOS

Минимум — iOS 15. Работают оба способа подключения: CocoaPods и Swift
Package Manager. В `ios/Podfile` приложения должно быть:

```ruby
platform :ios, '15.0'
```

### Android

Минимум — `minSdk 24`, AGP 8.x, KGP 1.9, Gradle 8.x, JDK 17.

Репозиторий с SDK объявляется в приложении:

```kotlin
// android/settings.gradle.kts, блок dependencyResolutionManagement
maven { url = uri("https://artifactory-external.vkpartner.ru/artifactory/maps-sdk-android/") }
```

> На 8 сентября 2026 этот адрес отдаёт 404: выкладка VK переехала, актуальные
> координаты запрошены у вендора. До ответа Android-часть не собирается.

## Что умеет

- камера: перемещение с анимацией, вписывание области, зум, поворот;
- маркеры декларативным набором, касания по ним;
- стили: готовые из SDK, JSON и по ссылке;
- источники и слои по спецификации Mapbox Style, рецепты `drawRoute`,
  `drawPolygon`, `drawCircle`;
- кластеризация на стороне Dart (`VkClusterizer`) — в нативном SDK её нет;
- события карты одним потоком плюс типизированные колбэки.

Что доступно на каждой платформе — в
[матрице поддержки](../../docs/platform-matrix.md).

## Чего пакет не делает

- **Не скрывает логотип VK.** В нативных SDK такой возможности нет, и
  атрибуция обязательна: доступны только выравнивание и отступы.
- **Не запрашивает геолокацию.** Координаты пользователя передаёт приложение
  через `controller.setUserLocation` — оно же решает вопрос с разрешениями.
- **Не поддерживает web.** Для веба у VK Карт есть собственный JavaScript SDK.

## REST-сервисы

Геокодинг, подсказки, маршруты, изохроны и остальное — отдельный пакет
[`vk_maps_api`](../vk_maps_api) без зависимости от Flutter.

```dart
final client = VkMapsApiClient(apiKey: 'ваш ключ');
final route = await client.routing.directions(<VkRouteLocation>[
  const VkRouteLocation(VkGeoPoint(55.796932, 37.537849)),
  const VkRouteLocation(VkGeoPoint(55.962139, 37.406377)),
]);
await controller.drawRoute(route.primary!.legs.first.encodedShape);
```

## Если карта не появилась

1. Проверьте, что `VkMaps.init` вызван до первой карты и ключ не пустой.
2. Посмотрите поток ошибок: `onError` виджета получает код и сообщение SDK.
3. На iOS убедитесь, что `platform :ios, '15.0'` стоит в `Podfile`.
4. На Android проверьте, что репозиторий с SDK доступен: сейчас это главная
   причина, по которой Android-часть не собирается.
