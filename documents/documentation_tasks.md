# Задачи по документации VK Карт

Одна страница документации — одна задача. Каждая проходит один и тот же цикл: **изучить → решить, нужно ли внедрять →
внедрить или записать отказ с причиной**. Отказ — это тоже результат: он фиксируется в `docs/platform-matrix.md`
(нет в нативном SDK) или в `docs/design-decisions.md` (сознательно не поддерживаем).

Снимки страниц лежат в [`research/dev_vk_ru/`](research/dev_vk_ru/) — снято 8 сентября 2026 скриптом
[`tool/fetch_docs.py`](../tool/fetch_docs.py); работать лучше со снимками, а обращаться к сайту при сверке.

**Статусы:** `не начата` · `изучена` · `внедрена` · `не требуется` · `заблокирована`.

Всего задач: 37.

## Общая информация

### Д-01. О VK Картах

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/general-information/general
- **Снимок:** [`research/dev_vk_ru/general-information/general.md`](research/dev_vk_ru/general-information/general.md)
- **Изучить:** Перечень сервисов, поддерживаемые платформы и языки, демосервер, каналы поддержки.
- **Внедрить:** Сверить охват `vk_maps_api` с перечнем сервисов; зафиксировать в README пакета, что поддержано, а что нет.
- **Пакет:** документация
- **Статус:** не начата

### Д-02. Использование API VK Карт

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/general-information/api-key
- **Снимок:** [`research/dev_vk_ru/general-information/api-key.md`](research/dev_vk_ru/general-information/api-key.md)
- **Изучить:** Базовый URL `https://maps.vk.com/api/{endpoint}`, `api_key` как query-параметр, демо-сервер, лимит 50 rps, статистика.
- **Внедрить:** `VkMapsApiClient(apiKey, baseUrl)`: подстановка ключа, демо-режим без ключа, троттлинг и понятная ошибка при 429.
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `VkMapsApiClient`: подстановка ключа, демо-режим, разбор конверта ошибок сервиса, тесты на 401/429/500 и не-JSON

## JavaScript SDK — эталон поверхности API

### Д-03. Общая информация

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/about
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/about.md`](research/dev_vk_ru/map-display-services/javascript-sdk/about.md)
- **Изучить:** Модель JS SDK: карта плюс объекты на ней.
- **Внедрить:** Внедрять нечего; используется как ориентир при проектировании Dart-API.
- **Пакет:** —
- **Статус:** не начата

### Д-04. Быстрый старт

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/quickstart
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/quickstart.md`](research/dev_vk_ru/map-display-services/javascript-sdk/quickstart.md)
- **Изучить:** Подключение через CDN и npm.
- **Внедрить:** Внедрять нечего; зафиксировать решение «web в 0.1.0 не поддерживаем».
- **Пакет:** —
- **Статус:** не начата

### Д-05. Карта

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/map
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/map.md`](research/dev_vk_ru/map-display-services/javascript-sdk/map.md)
- **Изучить:** Параметры конструктора, полный список методов и событий.
- **Внедрить:** Сверить Pigeon-контракт и `VkMapController` с этим списком; расхождения — в `docs/platform-matrix.md`.
- **Пакет:** platform_interface
- **Статус:** не начата

### Д-06. Методы `Map` (a…h)

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/map/methods-a-h
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/map/methods-a-h.md`](research/dev_vk_ru/map-display-services/javascript-sdk/map/methods-a-h.md)
- **Изучить:** 48 методов: `addControl`, `addImage`, `addLayer`, `addSource`, `cameraForBounds`, `easeTo`, `flyTo`, `fitBounds` и др.
- **Внедрить:** Камера, слои, источники и изображения в Dart-API — там, где есть аналог в нативном SDK.
- **Пакет:** platform_interface + фасад
- **Статус:** не начата

### Д-07. Методы `Map` (i…r)

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/map/methods-i-r
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/map/methods-i-r.md`](research/dev_vk_ru/map-display-services/javascript-sdk/map/methods-i-r.md)
- **Изучить:** 36 методов: `jumpTo`, `listImages`, `loadImage`, `moveLayer`, `on`/`off`, `queryRenderedFeatures`, `removeLayer` и др.
- **Внедрить:** Подписки на события, работа со слоями и запросы к отрендеренным объектам.
- **Пакет:** platform_interface + фасад
- **Статус:** не начата

### Д-08. Методы `Map` (s…z)

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/map/methods-s-z
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/map/methods-s-z.md`](research/dev_vk_ru/map-display-services/javascript-sdk/map/methods-s-z.md)
- **Изучить:** 48 методов: `setCenter`, `setStyle`, `setPaintProperty`, `setLayoutProperty`, `setFeatureState`, `zoomTo` и др.
- **Внедрить:** Сеттеры камеры и свойств стиля — основа JSON-first API стилей.
- **Пакет:** platform_interface + фасад
- **Статус:** не начата

### Д-09. События `Map`

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/map/events
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/map/events.md`](research/dev_vk_ru/map-display-services/javascript-sdk/map/events.md)
- **Изучить:** 48 событий: `click`, `drag*`, `move*`, `zoom*`, `data`, `idle`, `load`, `error` и др.
- **Внедрить:** Список событий моста и стримы `VkMapController`; что не поддержано нативным SDK — в матрицу.
- **Пакет:** platform_interface + фасад
- **Статус:** не начата

### Д-10. Классы событий

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/events
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/events.md`](research/dev_vk_ru/map-display-services/javascript-sdk/events.md)
- **Изучить:** `Evented`, `MapMouseEvent`, `MapTouchEvent`, `MapBoxZoomEvent`, `MapDataEvent`, `MapWheelEvent`.
- **Внедрить:** Dart-модели событий: координата, экранная точка, кнопка, фаза жеста.
- **Пакет:** platform_interface
- **Статус:** внедрена — модели событий карты в контракте плагина

### Д-11. География и геометрия

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/geometry
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/geometry.md`](research/dev_vk_ru/map-display-services/javascript-sdk/geometry.md)
- **Изучить:** `LngLat`, `LngLatBounds`, `Point`, `MercatorCoordinate`, `EdgeInsets`.
- **Внедрить:** `LatLon`, `LatLonBounds`, `ScreenPoint`, `EdgeInsets`; тест на порядок координат (`lon, lat` в JS — `lat, lon` в Dart-API).
- **Пакет:** platform_interface
- **Статус:** внедрена — `VkLatLon`, `VkLatLonBounds`, `VkEdgeInsets`, `VkScreenPoint` в контракте плагина

### Д-12. Обработчики жестов

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/handlers
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/handlers.md`](research/dev_vk_ru/map-display-services/javascript-sdk/handlers.md)
- **Изучить:** `BoxZoom`, `ScrollZoom`, `DragPan`, `DragRotate`, `Keyboard`, `DoubleClickZoom`, `TouchZoomRotate`, `TouchPitch`.
- **Внедрить:** Флаги включения жестов в конфигурации карты плюс проброс в нативные SDK.
- **Пакет:** фасад + натив
- **Статус:** не начата

### Д-13. Метки и элементы управления

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/labels-controls
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/labels-controls.md`](research/dev_vk_ru/map-display-services/javascript-sdk/labels-controls.md)
- **Изучить:** `Marker`, `Popup`, `IControl`, `NavigationControl`, `GeolocateControl`, `ScaleControl`, `FullscreenControl`.
- **Внедрить:** Маркеры и попапы — обязательно; контролы — нативными средствами, где есть, иначе Flutter-оверлеями поверх карты.
- **Пакет:** фасад
- **Статус:** не начата

### Д-14. Источники

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/sources
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/sources.md`](research/dev_vk_ru/map-display-services/javascript-sdk/sources.md)
- **Изучить:** `GeoJSONSource`, `VideoSource`, `ImageSource`, `CanvasSource`.
- **Внедрить:** GeoJSON- и Image-источники в API стилей; Video/Canvas пометить как web-only и не тащить.
- **Пакет:** фасад (стили)
- **Статус:** не начата

### Д-15. Объекты через GeoJSON

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/geojson
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/geojson.md`](research/dev_vk_ru/map-display-services/javascript-sdk/geojson.md)
- **Изучить:** Добавление объектов GeoJSON, пример с гексагонами.
- **Внедрить:** Приём GeoJSON в источники и рецепт в example.
- **Пакет:** фасад + example
- **Статус:** не начата

### Д-16. Кластеры

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/cluster
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/cluster.md`](research/dev_vk_ru/map-display-services/javascript-sdk/cluster.md)
- **Изучить:** HTML-кластеры на стороне JS.
- **Внедрить:** Кластеризация на стороне Dart — в нативном SDK её нет (см. находку 5 плана).
- **Пакет:** фасад
- **Статус:** не начата

### Д-17. Дополнительные объекты

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/additional-objects
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/additional-objects.md`](research/dev_vk_ru/map-display-services/javascript-sdk/additional-objects.md)
- **Изучить:** `AttributionControl`, `LngLatBoundsLike`.
- **Внедрить:** Атрибуция VK на карте (требование лицензии) и алиасы типов границ.
- **Пакет:** фасад
- **Статус:** не начата

### Д-18. Свойства и опции

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/options
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/options.md`](research/dev_vk_ru/map-display-services/javascript-sdk/options.md)
- **Изучить:** `accessToken`, `baseApiUrl`, `AnimationOptions`, `CameraOptions`, `PaddingOptions`, `RequestParameters`, `StyleImageInterface`, RTL-плагин.
- **Внедрить:** `CameraOptions`, `AnimationOptions`, `PaddingOptions` в Dart-API камеры; базовый URL — параметром конфигурации.
- **Пакет:** platform_interface
- **Статус:** внедрена — `VkCameraOptions`, `VkAnimationOptions`, отступы камеры

### Д-19. Использование в React

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/react
- **Снимок:** [`research/dev_vk_ru/map-display-services/javascript-sdk/react.md`](research/dev_vk_ru/map-display-services/javascript-sdk/react.md)
- **Изучить:** Пример интеграции карты в React-приложение.
- **Внедрить:** Внедрять нечего; полезно как образец структуры раздела «интеграция» в документации плагина.
- **Пакет:** —
- **Статус:** не начата

## Мобильные SDK

### Д-20. Maps SDK для Android

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/maps-mobile-sdk/android
- **Снимок:** [`research/dev_vk_ru/maps-mobile-sdk/android.md`](research/dev_vk_ru/maps-mobile-sdk/android.md)
- **Изучить:** Подключение (`maven` + `ru.mail.maps:mapkit`), `MapGlobalConfig.setMapGlobalConfig(MapViewConfig(apiKey))`, `MapStartOptions`, `LogoConfig`, `MapView`, `ZoomView`, `CurrentLocationView`, `CompassView`, minSdk 24.
- **Внедрить:** Пакет `vk_maps_mapkit_android`: platform view, конфигурация, контролы. **Блокировано:** обе `maven`-ссылки со страницы отдают 404 (см. находку 3 плана) — нужен адрес выкладки на Nexus.
- **Пакет:** vk_maps_mapkit_android
- **Статус:** не начата

### Д-21. MapsSDK для iOS

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/maps-mobile-sdk/ios
- **Снимок:** [`research/dev_vk_ru/maps-mobile-sdk/ios.md`](research/dev_vk_ru/maps-mobile-sdk/ios.md)
- **Изучить:** Подключение, управление картой, маркеры, кластеризация, попапы, стили, GeoJSON, пробки и изолинии, обработка ошибок, геокодирование, SwiftUI, ограничения.
- **Внедрить:** Пакет `vk_maps_mapkit_ios`. Сверить с DocC нативного SDK: страница описывает legacy-поколение, часть API отличается — расхождения зафиксировать.
- **Пакет:** vk_maps_mapkit_ios
- **Статус:** не начата

## Отображение карты

### Д-22. Статичная карта

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/static-map
- **Снимок:** [`research/dev_vk_ru/map-display-services/static-map.md`](research/dev_vk_ru/map-display-services/static-map.md)
- **Изучить:** `GET` и `POST /staticmap/png`, размеры, зум, коллекция булавок.
- **Внедрить:** Билдер URL для GET и запрос для POST (когда булавок много и URL не влезает).
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `VkStaticMapApi.urlForCenter`/`urlForBounds` с булавками и проверкой границ параметров

### Д-23. Стили карт

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/map-display-services/map-styles
- **Снимок:** [`research/dev_vk_ru/map-display-services/map-styles.md`](research/dev_vk_ru/map-display-services/map-styles.md)
- **Изучить:** Стили `main`, `dark`, `simple`; список пополняется.
- **Внедрить:** Enum предопределённых стилей со значением по умолчанию и возможностью задать свой id.
- **Пакет:** vk_maps_api + фасад
- **Статус:** не начата

## Маршрутизация

### Д-24. Построение маршрута

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/routing/direction
- **Снимок:** [`research/dev_vk_ru/routing/direction.md`](research/dev_vk_ru/routing/direction.md)
- **Изучить:** `/directions`: параметры запроса, структура ответа, примеры.
- **Внедрить:** Метод маршрутизации и модели ответа (`trips`, `legs`, `maneuvers`, `summary`).
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `VkRoutingApi.directions`, модели маршрута, участков и манёвров

### Д-25. Объекты costing options

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/routing/directions/costing-options
- **Снимок:** [`research/dev_vk_ru/routing/directions/costing-options.md`](research/dev_vk_ru/routing/directions/costing-options.md)
- **Изучить:** Опции стоимости по видам транспорта.
- **Внедрить:** Типобезопасные costing-опции вместо сырых `Map<String, dynamic>`.
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `costingOptions` кладутся под ключ выбранного транспорта

### Д-26. Пример ответа маршрута

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/routing/directions/response-example
- **Снимок:** [`research/dev_vk_ru/routing/directions/response-example.md`](research/dev_vk_ru/routing/directions/response-example.md)
- **Изучить:** Полный JSON ответа.
- **Внедрить:** Golden-тест парсера ровно на этом примере — фиксирует контракт и ловит регрессии.
- **Пакет:** vk_maps_api (тесты)
- **Статус:** внедрена — golden-тест парсера на полном примере ответа из документации

### Д-27. Декодирование ломаной

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/routing/decode-polyline
- **Снимок:** [`research/dev_vk_ru/routing/decode-polyline.md`](research/dev_vk_ru/routing/decode-polyline.md)
- **Изучить:** Алгоритм декодера на JS, C++ и Python; точность 1e6.
- **Внедрить:** Dart-декодер polyline и тест на порядок координат (в примерах он различается между языками).
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `VkPolyline.decode` с точностью 1e6 и тестами на порядок координат

### Д-28. Оптимальный маршрут

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/routing/optimal-route
- **Снимок:** [`research/dev_vk_ru/routing/optimal-route.md`](research/dev_vk_ru/routing/optimal-route.md)
- **Изучить:** `/optimal_route`: запрос, ответ, пример.
- **Внедрить:** Метод и модели.
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `VkRoutingApi.optimalRoute`

### Д-29. Матрица достижимости

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/routing/distance-matrix
- **Снимок:** [`research/dev_vk_ru/routing/distance-matrix.md`](research/dev_vk_ru/routing/distance-matrix.md)
- **Изучить:** `/dm`: запрос, ответ, пример.
- **Внедрить:** Метод и модели.
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `VkRoutingApi.distanceMatrix` с проверкой лимита в 50 точек

### Д-30. Область достижимости

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/routing/iso
- **Снимок:** [`research/dev_vk_ru/routing/iso.md`](research/dev_vk_ru/routing/iso.md)
- **Изучить:** `/iso`: запрос, ответ (GeoJSON), пример.
- **Внедрить:** Метод изохрон и разбор GeoJSON-ответа.
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `VkRoutingApi.isochrones`, разбор GeoJSON-контуров

## Поиск и геокодирование

### Д-31. Подсказчик

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/search-and-geocoding/suggest
- **Снимок:** [`research/dev_vk_ru/search-and-geocoding/suggest.md`](research/dev_vk_ru/search-and-geocoding/suggest.md)
- **Изучить:** `/suggest`: параметры, ответ, пример.
- **Внедрить:** Метод подсказок с отменой предыдущего запроса при вводе.
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `VkSearchApi.suggest`

### Д-32. Поиск мест интереса

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/search-and-geocoding/places
- **Снимок:** [`research/dev_vk_ru/search-and-geocoding/places.md`](research/dev_vk_ru/search-and-geocoding/places.md)
- **Изучить:** `/places`: `fields`, `location`, `limit`, ответ.
- **Внедрить:** Метод поиска POI и модели `place_details`.
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `VkSearchApi.places`

### Д-33. Геокодирование

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/search-and-geocoding/geocoding
- **Снимок:** [`research/dev_vk_ru/search-and-geocoding/geocoding.md`](research/dev_vk_ru/search-and-geocoding/geocoding.md)
- **Изучить:** `/search`: прямое и обратное, конверт `{request, results}`, `pin` = `[lon, lat]`.
- **Внедрить:** Прямой и обратный геокодинг; парсер, скрывающий порядок координат, и тесты на расхождения из находки 7 плана.
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `VkSearchApi.geocode` и `reverseGeocode`; порядок координат у входов проверен на демо-сервере

## Дополнительные сервисы

### Д-34. Профиль высот

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/additional-services/elevation
- **Снимок:** [`research/dev_vk_ru/additional-services/elevation.md`](research/dev_vk_ru/additional-services/elevation.md)
- **Изучить:** `/elevation`: POST с полем `json`, ответ, примеры.
- **Внедрить:** Метод профиля высот (нестандартная форма запроса — покрыть тестом).
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `VkExtrasApi.elevation`, включая режим `range`

### Д-35. Местоположение по IP

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/additional-services/ip2geo
- **Снимок:** [`research/dev_vk_ru/additional-services/ip2geo.md`](research/dev_vk_ru/additional-services/ip2geo.md)
- **Изучить:** `/ip2geo`: запрос, ответ, пример.
- **Внедрить:** Метод плюс обработка расхождения `geoid`/`geo_id` между таблицей и примером.
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `VkExtrasApi.ip2geo`, читаются оба написания идентификатора региона

### Д-36. Часовой пояс

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/additional-services/timezone
- **Снимок:** [`research/dev_vk_ru/additional-services/timezone.md`](research/dev_vk_ru/additional-services/timezone.md)
- **Изучить:** `/timezone`: запрос, ответ.
- **Внедрить:** Метод и модель часового пояса.
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `VkExtrasApi.timezone`

### Д-37. Почтовый индекс

- **Ссылка:** https://dev.vk.ru/ru/vkmaps/additional-services/postcode
- **Снимок:** [`research/dev_vk_ru/additional-services/postcode.md`](research/dev_vk_ru/additional-services/postcode.md)
- **Изучить:** `/postcode`: ответ, пример.
- **Внедрить:** Метод поиска по индексу.
- **Пакет:** vk_maps_api
- **Статус:** внедрена — `VkExtrasApi.postcode`

---

**Правило закрытия задачи:** задача считается закрытой, когда в коде есть либо реализация, либо тест, либо строка в
`docs/platform-matrix.md`/`docs/design-decisions.md` с причиной отказа. Ссылка на страницу в коде не дублируется —
источник указывается в шапке снимка.
