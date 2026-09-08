# План разработки `vk_maps_flutter` — Flutter-обёртка над нативными SDK VK Карт

**Статус:** планируется.

**Дата составления:** 8 сентября 2026.

**Цель:** federated Flutter-плагин, который показывает карту VK Карт через нативные SDK (Android и iOS), даёт Dart-API
для камеры, маркеров, стилей, источников и слоёв, а также чистый Dart-клиент к REST-сервисам VK Карт (геокодинг,
подсказки, POI, маршруты, изохроны, матрица расстояний, высоты, статическая карта, ip2geo, таймзоны, индексы).

**Образцы:** структура репозитория и правила публикации — по `apptracer_flutter`
(`../apptracer_flutter/docs/design-decisions.md`, `docs/publishing.md`, `tool/check.sh`, `Makefile`); формат этого
плана — по `../farming/documents/architecture_refactoring_plan.md`.

**Правило графика:** не более **двух** задач в день; **одна сложная** задача занимает **целый день**.

**Задачи по документации:** [`documentation_tasks.md`](documentation_tasks.md) — 37 задач, по одной на страницу
документации VK Карт: изучить, решить, нужно ли внедрять, внедрить или записать отказ с причиной. Снимки страниц —
в [`research/dev_vk_ru/`](research/dev_vk_ru/).

---

## 1. Что прочитано и что из этого следует

Все 45 страниц документации с `dev.vk.ru/ru/vkmaps` прочитаны успешно, ни одна не упала. 37 из них сняты в
Markdown скриптом [`../tool/fetch_docs.py`](../tool/fetch_docs.py) и лежат в [`research/dev_vk_ru/`](research/dev_vk_ru/)
— по каждой заведена задача в [`documentation_tasks.md`](documentation_tasks.md). Дополнительно изучены
GitHub-репозитории `maps-mailru/maps-sdk-ios` (legacy) и `maps-mailru/vk-maps-distribution` (актуальный SDK), DocC-архив
`MapsNativeSDK` и podspec `VKMapsSDK`. Выжимки лежат в [`research/`](research/).

**Источник API — документация нативных SDK.** Обвязка пишется поверх нативных пакетов (`VKMapsSDK` на iOS,
`com.vk.maps:maps-native-sdk` на Android); поверхность API берётся из DocC-архива и документации вендора.
Сторонние и снятые с публикации Flutter-плагины источником контракта не являются и в план не входят.

| Раздел документации | Страниц | Результат | Что важно для плана |
| --- | ---: | --- | --- |
| Общая информация, API-ключ | 2 | прочитано | ключ — query-параметр `api_key`; лимит 50 rps; демо-сервер `demo.maps.vk.com` без ключа |
| Mobile SDK Android, iOS | 2 | прочитано | **описан legacy WebView-SDK** (`ru.mail.maps:mapkit`, SPM `MapsSDK`), бинарники — 404 |
| JavaScript SDK | 17 | прочитано | `mmr-gl`, форк Mapbox GL JS v2; только Marker/Popup, фигуры — source + layer |
| Статическая карта, стили | 2 | прочитано | `/staticmap/png` GET и POST; стили `main`, `dark`, `simple` |
| Маршрутизация | 7 | прочитано | Valhalla-подобный API: `/directions`, `/optimal_route`, `/dm`, `/iso`; polyline 1e6 |
| Поиск и геокодинг | 3 | прочитано | `/suggest`, `/places`, `/search`; конверт `{request, results}`; `pin` = `[lon, lat]` |
| Дополнительные сервисы | 4 | прочитано | `/elevation` (POST с полем `json`), `/ip2geo`, `/timezone`, `/postcode` |

### Ключевые находки

1. **Два поколения мобильных SDK.** Страницы `maps-mobile-sdk/android` и `maps-mobile-sdk/ios` описывают legacy SDK
   (Android `ru.mail.maps:mapkit`, iOS `MapsSDK` 1.1.48, апрель 2024) — это `WKWebView`/WebView вокруг JS-карты.
   Актуальный SDK — **нативный** (`MapsNativeSDK`/`VKMapsSDK` на iOS, `com.vk.maps:maps-native-sdk` на Android,
   релиз 1.4.4.14633 от 26 августа 2026, рендер Metal/Vulkan). На сайте документации он не описан; API берётся из
   DocC-архива `MapsNativeSDK` и ответов вендора. **План строится на нативном SDK.**
2. **Артефакты Android недоступны публично.** Maven-репозиторий
   `https://artifactory-external.vkpartner.ru/artifactory/maps-sdk-android` отвечает 404 на все проверенные пути;
   сам хост `artifactory-external.vkpartner.ru/artifactory/` редиректит на `https://nexus-external.vkteam.ru/` —
   выкладка переехала с Artifactory на Nexus. В публичном списке Nexus 28 репозиториев, ни одного maps, поиск по
   `com.vk.maps` и `maps-native-sdk` пуст. Зеркала на Maven Central нет (`g:com.vk.maps` → 0). Проверено
   8 сентября 2026. iOS-бинарники доступны: GitHub Releases `maps-mailru/vk-maps-distribution` (тег 1.4.4.14633,
   xcframework-архивы + `VKMapsSDK.zip`) и CocoaPods `VKMapsSDK`. Нужны координаты Android-выкладки на Nexus и,
   вероятно, доступ — без этого этап Android не стартует. То же касается legacy-координат `ru.mail.maps:mapkit`
   из документации (п. 3): путь 404.
3. **Документация Android SDK описывает `ru.mail.maps:mapkit`, а её Maven-ссылка мертва.** Страница
   `https://dev.vk.ru/ru/vkmaps/maps-mobile-sdk/android` доступна (проверено 8 сентября 2026) и даёт API:
   `MapGlobalConfig.setMapGlobalConfig(MapViewConfig(apiKey))`, `MapStartOptions(center, zoomLevel, style,
   compassLocationMode, logoConfig)`, `MapView`, `ZoomView`, `CurrentLocationView`, `CompassView`. Но обе
   Maven-ссылки со страницы — `.../artifactory/maps-sdk-android/` и
   `.../artifactory/maps-sdk-android/ru/mail/maps/mapkit/` — отдают 404, причём страницу 404 рисует уже Sonatype
   Nexus 3.91.1: документация ссылается на путь Artifactory, которого на новом хосте нет. Домен документации —
   `dev.vk.ru` (не `.com`); `platform.vk.com/docs/vkmaps/*` требует вход в VK.
4. **Нативный SDK не MapLibre.** Собственный движок VK, но стили, источники и слои — Mapbox Style Spec JSON. Значит,
   Dart-API стилей можно проектировать как «JSON-first» без выдумывания собственной модели слоёв.
5. **Кластеризации в нативном SDK нет.** В DocC-символах нативного SDK нет ни одного `Cluster`-типа;
   `addCluster`/`removeCluster` есть только в legacy WebView-SDK. Кластеризацию делать на Dart-стороне или ждать SDK.
6. **REST-сервисы не требуют нативного кода.** Весь блок «поиск, маршруты, дополнительные сервисы» — чистый Dart с
   `http`, тестируется без устройств и может публиковаться отдельным пакетом.
7. **Расхождения в документации**, которые надо закрепить тестами: `pin` в результатах — `[lon, lat]`, а у
   `entrances[].pin` в примере — `[lat, lon]`; `ip2geo` в таблице `geoid`, в примере `geo_id`; `wheelchare` (sic);
   Python-пример декодера polyline отдаёт `[lon, lat]`, JS — `[lat, lon]`; формат ошибок и HTTP-коды не описаны.

---

## 2. Общие правила разработки

1. Одна ответственность — один пакет. Federated-плагин: фасад, `platform_interface`, `android`, `ios`; REST — отдельный
   чистый Dart-пакет без зависимости от Flutter.
2. Мост Dart ↔ native — **Pigeon**, а не ручной `MethodChannel`: поверхность API большая (десятки методов, вложенные
   модели), типизированный кодоген дешевле ручной сериализации. Ручные каналы — только для потока событий, если Pigeon
   `@FlutterApi` окажется неудобен.
3. Нативные SDK не вендорятся: Android — `implementation` из Maven VK, iOS — `s.dependency 'VKMapsSDK'` и SPM-пакет
   `vk-maps-distribution`. Версия SDK закрепляется в одном месте на платформу и поднимается отдельным коммитом.
   Оба современных способа подключения обязательны и проверяются в CI: **SPM на iOS** (наравне с CocoaPods) и
   **KGP с декларативным `plugins {}` на Android** (наравне со старым `apply plugin:`) — см. этапы 3 и 4.
4. Dart-модели — immutable, с `==`/`hashCode`, без `freezed` в публичных пакетах (меньше транзитивных зависимостей у
   потребителя). Координаты в Dart-API всегда `LatLon(latitude, longitude)`; конвертация `[lon, lat]` REST-ответов
   спрятана в парсерах и покрыта тестами.
5. Ничего не публикуется как `1.0.0`, пока не подтверждена живая проверка на устройстве по каждой платформе
   (правило из `apptracer_flutter/docs/status.md`).
6. Каждый этап заканчивается зелёным `tool/check.sh` (format, analyze `--fatal-infos`, test, `pub publish --dry-run`)
   и записью в `CHANGELOG.md` затронутых пакетов.
7. Секреты (`api_key`) не попадают в репозиторий: `--dart-define=VK_MAPS_API_KEY`, `~/.vk-maps-env` для `Makefile`, как
   `~/.tracer-env` в образце.
8. Все описания в документах и коммитах — на русском; идентификаторы, файлы и команды — в обратных кавычках.

Целевая структура репозитория:

```text
vk_maps/
  packages/
    vk_maps_flutter/                     # фасад: VkMap widget, VkMapController, реэкспорт моделей
    vk_maps_flutter_platform_interface/  # VkMapsPlatform, модели, pigeon-контракт (generated)
    vk_maps_flutter_android/             # Kotlin: platform view + мост к com.vk.maps
    vk_maps_flutter_ios/                 # Swift: platform view + мост к MapsNativeSDK (podspec + Package.swift)
    vk_maps_api/                         # чистый Dart: REST-клиент, polyline-декодер, static map URL builder
  tool/      bootstrap.sh, check.sh
  docs/      design-decisions.md, platform-matrix.md, publishing.md, status.md, questions-for-vendor.md
  documents/ development_plan.md, research/
  Makefile, README.md, README.en.md, LICENSE, .github/workflows/{ci.yml,ios.yml}
```

Целевое направление зависимостей:

```text
VkMap (widget) -> VkMapController -> VkMapsPlatform -> PigeonHostApi -> native MapView
vk_maps_api    -> http                (никаких Flutter-зависимостей)
```

---

## 3. Что заимствуем у пакетов-конкурентов

Разобраны два пакета: [`yandex/yandex_maps_mapkit`](https://github.com/yandex/yandex_maps_mapkit) 4.42.0 — обёртка
над нативным MapKit, ровно тот же класс задачи, и
[`google_maps_flutter`](https://github.com/flutter/packages/tree/main/packages/google_maps_flutter) — эталонный
federated-плагин от команды Flutter. Ниже — только то, что берём, с указанием этапа.

| Что берём | Где подсмотрено | Куда |
| --- | --- | --- |
| Декларативные наборы объектов вместо императивных `add`/`remove` | `GoogleMap(markers: Set<Marker>, polylines: …)` | этап 5 |
| Диффы: `MapsObjectUpdates.from(previous, current)` → `objectsToAdd` / `objectsToChange` / `objectIdsToRemove`, в натив уходит только дельта | `maps_object_updates.dart`, по тесту на каждый тип объекта | этапы 5, 6 |
| Дельта конфигурации: `MapConfiguration.diffFrom(prev)`, пустой апдейт не уходит в натив | `_updateOptions` в `google_map.dart` | этап 5 |
| Фейковая платформа для тестов фасада без устройства | `test/fake_google_maps_flutter_platform.dart` | этап 5 |
| Раскладка `platform_interface`: `src/types`, `src/events`, `src/platform_interface`, `src/method_channel` | `google_maps_flutter_platform_interface` | этапы 1, 2 |
| `@ConfigurePigeon(PigeonOptions(dartOut:…, kotlinOut:…, copyrightHeader:))` в `pigeons/messages.dart` | оба платформенных пакета Google | этап 2 |
| `false_secrets` в pubspec для example с демо-ключом, `issue_tracker`, `topics` | `google_maps_flutter/pubspec.yaml` | этап 9 |
| Раскладка SPM: `ios/<пакет>.podspec` и `ios/<пакет>/Package.swift` с `Sources/` рядом | `yandex_maps_mapkit` (у `google_maps_flutter_ios` SPM ещё нет) | этап 4 |
| Режим platform view — параметр виджета, а не хардкод: `PlatformViewType { Hybrid, Virtual, TextureHybrid, Compat }` | `platform_view_type.dart` | этап 5 |
| Проброс `gestureRecognizers` и `hitTestBehavior` из виджета в platform view | `platform_view_widget.dart` | этап 5 |
| Явный жизненный цикл SDK: `onStart()` / `onStop()` + `flutter_plugin_android_lifecycle` | `mapkit.dart`, pubspec Яндекса | этапы 3, 5 |
| Идемпотентная инициализация одним вызовом: `initMapkit(apiKey:, locale:, userId:, options:)`, повторный вызов не переинициализирует | `bindings/init.dart` | этап 5 |

Опорные версии Android-обвязки у Яндекса (полезно как точка в матрице KGP): AGP 8.6.0, KGP 2.0.21, JDK 21,
`compileSdk 35`, `minSdk 26`, нативная зависимость подключена как `api`, а не `implementation`.

**Что рассмотрено и отвергнуто.** Яндекс генерирует Dart-биндинги поверх `dart:ffi` — 1199 файлов в `lib/`,
собственный кодоген на `build_runner` (`weak_interfaces_meta_generator`, `container_generator`). Это оправдано при
их размере SDK и наличии IDL. У VK Карт публичного IDL нет, поверхность на порядок меньше, а FFI тянет за собой
ручное управление памятью и изоляты. Остаёмся на Pigeon (правило 2 раздела 2).

**Решения, которые надо принять явно и записать в `docs/design-decisions.md`:**
1. Pigeon-контракт общий в `platform_interface` (как задумано) против отдельного `pigeons/messages.dart` в каждом
   платформенном пакете (как у Google — это позволяет платформам расходиться в возможностях).
2. `api` против `implementation` для нативной зависимости в Gradle: `api` открывает приложению нативные типы VK
   (гибкость для сложных кейсов), `implementation` держит SDK за фасадом и не ломает пользователя при смене версии.

---

## 4. Этап 0 — доступы, проверка артефактов и решение по SDK

**Приоритет:** P0.
**Сложность:** M.
**Зависимость:** —.
**Статус:** не начат.

### Задачи

1. Запросить API-ключ на `https://maps.vk.com/ru/welcome/`; до ответа использовать `demo.maps.vk.com` для REST.
2. Написать в `support.maps@lists.vk.team`: (1) актуальные координаты Android-выкладки `com.vk.maps:maps-native-sdk`
   на `nexus-external.vkteam.ru` (имя репозитория, нужны ли креды) и список доступных версий; (2) есть ли
   документация нативного Android SDK (аналог DocC) и где она; (3) есть ли кластеризация и Polyline-source в
   нативном SDK; (4) условия EULA `https://help.mail.ru/legal/terms/maps/terms` для стороннего open-source плагина.
   Вопросы и ответы фиксировать в `docs/questions-for-vendor.md`.
3. Проверить скриптом доступность артефактов и зафиксировать результат в `docs/platform-matrix.md`:
   `pod spec cat VKMapsSDK`, `swift package resolve` на `vk-maps-distribution` 1.4.4.14633, `curl` по Nexus
   (`/service/rest/v1/repositories`, `/service/rest/v1/search?group=com.vk.maps`) и по старым Maven-путям Artifactory.
4. Составить таблицу поверхности API нативного SDK по документации: распаковать `MapsNativeSDK.doccarchive` из
   релиза 1.4.4.14633, выгрузить символы (контроллеры камеры, оверлеев, пользовательской точки, `Style`, слушатели
   событий) в `docs/native-api-surface.md`; для Android — то же по документации вендора после ответа на п. 2.
   Эта таблица — основа Pigeon-контракта этапа 2.
5. Закрепить решение в `docs/design-decisions.md`: нативный SDK, Pigeon, federated-структура, отсутствие web в первом
   релизе, версии SDK (iOS 1.4.4.14633; Android — по ответу вендора).

### Критерии готовности

- Есть API-ключ или подтверждено, что демо-сервера хватает для этапов 1–2 и 7.
- `docs/platform-matrix.md` содержит проверенные датой факты о доступности артефактов на каждой платформе.
- Письмо вендору отправлено, вопросы записаны. Решение «Android блокирован / не блокирован» принято явно.
- `docs/design-decisions.md` содержит пять решений выше с обоснованием.

---

## 5. Этап 1 — скелет монорепозитория

**Приоритет:** P0.
**Сложность:** M.
**Зависимость:** этап 0 (п. 5).
**Статус:** не начат.

### Задачи

1. Разобраться с git: сейчас `vk_maps/` лежит внутри чужого репозитория `projects/.git` (`git rev-parse --show-toplevel`
   → `projects`). Создать собственный `.git` в `vk_maps/`, `.gitignore` по образцу `apptracer_flutter`.
2. Создать пять пакетов через `flutter create --template=plugin` / `package` с `pubspec_overrides.yaml` для локальной
   связки (без melos, как в образце). Имена и `flutter.plugin.platforms` с `default_package` в фасаде.
3. `tool/bootstrap.sh`, `tool/check.sh` (порядок: platform_interface → api → android → ios → фасад), `Makefile` с
   целями `bootstrap`, `check`, `format`, `analyze`, `test`, `gen` (pigeon), `example-android`, `example-ios`,
   `pod-install`, `tokens`.
4. `.github/workflows/ci.yml` (matrix по пакетам, `--fatal-infos`, `publish --dry-run`) и `ios.yml` (macOS-раннер,
   path-filter на `packages/vk_maps_flutter_ios/**`).
5. Общий `analysis_options.yaml` (`flutter_lints`), `LICENSE` (MIT для обёртки; EULA SDK — ссылкой в README), `CHANGELOG.md`
   в каждом пакете по Keep a Changelog, `README.md`/`README.en.md` с таблицей документов.
6. `docs/status.md` — леджер «что проверено вживую», изначально всё «не проверено».

### Критерии готовности

- `make bootstrap && make check` зелёный на пустых пакетах; CI проходит на `main`.
- `dart pub publish --dry-run` без предупреждений во всех публикуемых пакетах.

---

## 6. Этап 2 — контракт: `platform_interface` и Pigeon

**Приоритет:** P0.
**Сложность:** L.
**Зависимость:** этап 1.
**Статус:** не начат.

### Задачи

1. Dart-модели в `vk_maps_flutter_platform_interface/lib/src/models/`: `LatLon`, `LatLonBounds`, `ViewPoint`,
   `MapPadding`, `CameraPosition` (center, zoom, bearing, pitch), `CameraOptions`, `AnimationOptions` (easing,
   duration), `CameraMovingReason`, `CameraMovingPhase`, `MapMode` (`free`, `followLocation`,
   `followBearingAndLocation`), `MapPredefinedStyle` (`simple`, `main`, `dark`, `navigationMain`, `navigationDark`,
   `simpleDark`, `grayLight`), `Marker` (id, position, imageId, anchor, offset, zIndex), `MarkerAnchor`,
   `LogoConfig`, `VkMapConfiguration` (apiKey, baseUrl, cache, locale, initial camera, style, featuresSelectionMode),
   `MapEvent` (sealed: `mapShown`, `styleSet`, `styleApplied`, `cameraMove`, `tap`, `longTap`, `markerTap`,
   `featureTap`, `tileFailed`, `lowMemory`, `gpuError`), `MapError`.
2. `pigeons/vk_maps.dart`: `@HostApi VkMapsHostApi` (инициализация SDK, camera-, overlay-, userPointer-, style-,
   controls-группы — по таблице этапа 0 п. 4), `@HostApi VkMapsStyleApi` (create*, addSource, setGeoJson,
   setEncodedPolyline, add/insert/removeLayer, setLayerVisibility, addImage, addSvgImage, removeImage),
   `@FlutterApi VkMapsFlutterApi` (onEvent, onError, onModeChanged). Каждый вызов принимает `viewId`, чтобы
   поддерживать несколько карт на экране.
3. `VkMapsPlatform extends PlatformInterface` с token; `PigeonVkMapsPlatform` — реализация по умолчанию.
4. Кодоген: `make gen` → `lib/src/generated/vk_maps.g.dart`, `android/.../VkMaps.g.kt`, `ios/.../VkMaps.g.swift`
   в соответствующих пакетах. Сгенерированные файлы коммитятся.
5. Тесты моделей (равенство, `toString`, границы zoom 0…22, pitch, bearing 0…360) и тест токена платформы.
6. Раскладка пакета — как в `google_maps_flutter_platform_interface`: `src/types` (модели), `src/events` (события),
   `src/platform_interface` (абстракция), `src/method_channel` (реализация по умолчанию). Решение «общий контракт
   против `pigeons/messages.dart` на каждый платформенный пакет» принять явно и записать в `docs/design-decisions.md`
   (см. раздел 3).

### Критерии готовности

- Контракт покрывает поверхность API из `docs/native-api-surface.md` плюс `viewId`; нет методов, у которых нет
  соответствия в обоих нативных SDK (иначе — в `docs/platform-matrix.md` как «только iOS/только Android»).
- `dart run pigeon` воспроизводим, `make gen` идемпотентен, diff после повторного запуска пуст.

---

## 7. Этап 3 — Android

**Приоритет:** P0.
**Сложность:** XL.
**Зависимость:** этап 2; разблокировка Maven-репозитория (этап 0 п. 2–3).
**Статус:** не начат.

### Задачи

1. `android/build.gradle`: AGP 8.x, Kotlin, `compileSdk 35`, `minSdk 24`, NDK `25.2.9519653`, Maven VK,
   `implementation "com.vk.maps:maps-native-sdk:$vkMapsSdkVersion"`, `packagingOptions.jniLibs.pickFirsts` для
   `libVkLayer_khronos_validation.so`, `res/values/styles.xml` с `MapSDKTheme`, `consumer-rules.pro`.
   Манифест: `INTERNET`; `ACCESS_*_LOCATION` — не объявлять в плагине, оставить приложению (документировать).
2. `VkMapsFlutterPlugin` (`FlutterPlugin`, `ActivityAware`), `VkMapViewFactory` (`PlatformViewFactory`, viewType
   `vk_maps_flutter/map`), `VkMapPlatformView` с `com.vk.maps.MapView(ContextThemeWrapper(context, R.style.MapSDKTheme))`,
   `applyConfig`, `RenderTarget.Texture`; `MapsSdk.setup` один раз на процесс.
3. Реализация `VkMapsHostApi`/`VkMapsStyleApi` поверх `cameraController`, `overlayController`,
   `userPointerController`, `Style` (`createEmpty/FromJson/FromUrl/WithPredefinedStyle` — вне main thread,
   ответ через `Result`). Реестр стилей по id — на стороне плагина.
4. События: `eventsListener`, `errorListener`, `modeUpdateListener`, `nextModeListener` → `VkMapsFlutterApi`; все
   вызовы в Dart строго на main thread (`Handler(Looper.getMainLooper())`).
5. Жизненный цикл: `dispose` platform view освобождает `MapView` и стили; повторное создание карты после `dispose`
   не падает; поворот экрана.
6. Unit-тесты Kotlin для маппинга enum/моделей (JUnit, как `android/src/test/kotlin` в образце).
7. **Поддержка KGP (Kotlin Gradle Plugin).** Плагин должен собираться у приложений и на старом, и на новом
   Android-обвязе Flutter: объявление через декларативный блок `plugins { id "com.android.library"; id
   "org.jetbrains.kotlin.android" }` вместо `apply plugin:`, совместимость с загрузчиком плагинов из
   `settings.gradle`/`settings.gradle.kts`. Версия KGP не прибивается жёстко: берётся из версии, объявленной
   приложением, а в плагине фиксируется только минимально поддерживаемая. Составить и держать в
   `docs/platform-matrix.md` матрицу совместимости AGP × KGP × Gradle × JDK (минимум: KGP 1.9.x и 2.x, AGP 8.x,
   Gradle 8.x, JDK 17) и прогонять сборку example по её углам. `build.gradle.kts` в примере — как отдельная
   проверка, что Kotlin DSL у потребителя не ломается. Опорная точка — обвязка Яндекса: AGP 8.6.0, KGP 2.0.21,
   JDK 21, `compileSdk 35`.
8. Жизненный цикл активити через `flutter_plugin_android_lifecycle`: карта освобождает ресурсы и глушит сетевые
   запросы в фоне, возобновляет при возврате (у Яндекса это вынесено в явные `onStart`/`onStop`).

### Критерии готовности

- Карта из example рисуется на эмуляторе API 35 и физическом устройстве; камера, маркер, смена стиля, tap-события
  работают; `dispose`/пересоздание без утечек и крашей.
- `./gradlew :vk_maps_flutter_android:testDebugUnitTest` в CI зелёный.
- Матрица AGP × KGP × Gradle × JDK заполнена, сборка example зелёная на минимальной и максимальной точках;
  приложение на Groovy DSL и приложение на Kotlin DSL подключают плагин без правок в своём проекте.

---

## 8. Этап 4 — iOS

**Приоритет:** P0.
**Сложность:** XL.
**Зависимость:** этап 2. Не зависит от Android — может идти параллельно с этапом 3.
**Статус:** не начат.

### Задачи

1. `ios/vk_maps_flutter_ios.podspec`: `s.platform = :ios, '15.0'`, `s.swift_version = '5.10'`,
   `s.dependency 'VKMapsSDK', '~> 1.4'`, `EXCLUDED_ARCHS[sdk=iphonesimulator*] = i386`; параллельно
   `ios/vk_maps_flutter_ios/Package.swift` с `.package(url: "https://github.com/maps-mailru/vk-maps-distribution.git",
   .upToNextMajor(from: "1.4.4"))`, продукт `MapsNativeSDK` — как двойная сборка в образце.
2. `VkMapsFlutterPlugin` (`FlutterPlugin`), `VkMapViewFactory` (`FlutterPlatformViewFactory`), `VkMapPlatformView`
   с `MapView(frame:configuration:delegate:)`; `MapsSDKConfigurator.setup(apiKey:)` один раз.
3. Реализация `VkMapsHostApi`/`VkMapsStyleApi` поверх `mapView.camera`, `mapView.overlay`, `mapView.userPointer`,
   `MapStyle` (async/await → `completion`). Учесть, что делегат может звать не из main thread — маршалить в
   `DispatchQueue.main` перед `FlutterApi`.
4. `MapViewDelegate` → `VkMapsFlutterApi`: `didReceiveEvent`, `willChangeModeTo`, `didChangeModeTo`, `didFailWithError`.
5. Жизненный цикл: освобождение `MapView` в `deinit`, память при нескольких картах, background/foreground.
6. **Поддержка SPM (Swift Package Manager).** Плагин публикуется в двух режимах подключения одновременно:
   CocoaPods (`.podspec`) и SPM (`ios/vk_maps_flutter_ios/Package.swift` в раскладке, которую ищет Flutter:
   подспек в `ios/`, рядом каталог пакета с `Package.swift` и `Sources/<имя>/*.swift` — как сделано в
   `yandex_maps_mapkit`; у `google_maps_flutter_ios` SPM пока нет, поэтому образец берём у Яндекса).
   Зависимость на SDK в SPM-режиме — пакет `maps-mailru/vk-maps-distribution`, в CocoaPods-режиме — под
   `VKMapsSDK`; версия SDK задаётся в одном месте и не расходится между режимами. Проверять оба пути:
   `flutter config --enable-swift-package-manager` и сборку с выключенным SPM (fallback на pods), плюс
   `pod lib lint`. Ресурсы и `.modulemap`, если появятся, объявлять так, чтобы работали в обоих режимах.

### Критерии готовности

- Карта из example рисуется на симуляторе и физическом устройстве iOS 15+; тот же сценарий, что в п. 3.
- `ios.yml` в CI собирает example в обоих режимах (pods, SPM) без предупреждений линтера подспека.
- Приложение с включённым SPM собирается без `Podfile`, приложение без SPM — через CocoaPods; версия SDK в обоих
  режимах одна и та же.

---

## 9. Этап 5 — Dart-фасад: виджет, контроллер, события, маркеры

**Приоритет:** P0.
**Сложность:** L.
**Зависимость:** этап 2; для живой проверки — этап 3 или 4.
**Статус:** не начат.

### Задачи

1. `VkMap` — `StatefulWidget` с `AndroidView`/`UiKitView`, параметры: `configuration`,
   `onMapCreated(VkMapController)`, `initialCameraPosition`, `style`, `gestureRecognizers`, `hitTestBehavior`,
   флаги controls и жестов, плюс `platformViewType` (`hybrid` / `virtual` / `textureHybrid` / `compat`,
   по умолчанию `compat`) — режим композиции выбирает приложение, а не плагин (как у Яндекса).
   Объекты карты задаются декларативно наборами: `markers: Set<VkMarker>`, дальше `polylines`, `polygons`, `circles`
   по мере поддержки (как `GoogleMap`), а не только императивными методами контроллера.
2. `VkMapController`: `camera` (`flyTo`, `easeTo`, `jumpTo`, `fitBounds`, `setZoom/Bearing/Pitch/Padding`, `zoomIn/Out`,
   `getCameraPosition`, `getVisibleBounds`, проекции `toScreen`/`fromScreen`, `metersPerPoint`), `markers`
   (`add`, `addAll`, `remove`, `removeAll`, `update`), `userLocation` (`set`, `setBearing`, `visible`), `mode`
   (`set`, `setNextModes`), `controls` (zoom buttons, compass, my-location, gestures).
3. Потоки событий: `Stream<MapEvent> events`, типизированные `onTap`, `onLongTap`, `onMarkerTap`, `onCameraMove`,
   `onCameraIdle`, `onStyleLoaded`, `onError`. Диспетчер по `viewId` в `platform_interface`.
4. Стратегия ошибок: `VkMapsException` с кодом и платформенным сообщением; `PlatformException` не протекает наружу.
5. Диффы вместо полной перезаливки: `VkMapsObjectUpdates.from(previous, current)` считает
   `objectsToAdd` / `objectsToChange` / `objectIdsToRemove`, в натив уходит только дельта; `didUpdateWidget`
   пересчитывает и наборы объектов, и конфигурацию (`VkMapConfiguration.diffFrom`), пустой апдейт не отправляется.
   Тест на диффы — отдельным файлом на каждый тип объекта (как у Google).
6. Инициализация SDK: `VkMaps.init(apiKey:, locale:, options:)` до первой карты, идемпотентная — повторный вызов
   не переинициализирует нативный SDK и не роняет приложение (как `initMapkit` у Яндекса).
7. Жизненный цикл: карта останавливает рендер и сетевые запросы, когда приложение уходит в фон, и возобновляет при
   возврате (`onStart`/`onStop` нативного SDK, на Android — через `flutter_plugin_android_lifecycle`).
8. Widget-тесты с фейковым `VkMapsPlatform` (регистрация карты, доставка событий, dispose снимает подписки).

### Критерии готовности

- Публичный API фасада документирован dartdoc-комментариями; `dart doc` без предупреждений.
- Widget-тесты покрывают жизненный цикл и маршрутизацию событий для двух одновременных карт.
- Тесты диффов: добавление, изменение и удаление объекта дают ровно один вызов моста с ожидаемой дельтой;
  повторная сборка виджета с теми же наборами не даёт вызовов вообще.

---

## 10. Этап 6 — стили, источники, слои, изображения

**Приоритет:** P1.
**Сложность:** L.
**Зависимость:** этап 5.
**Статус:** не начат.

### Задачи

1. `VkMapStyle`: `predefined(...)`, `fromJson`, `fromUrl`, `empty`; `controller.setStyle`, `releaseStyle`; кэш стилей по id.
2. Источники и слои JSON-first: `addGeoJsonSource(id, FeatureCollection | String)`, `setGeoJson`,
   `addEncodedPolylineSource(id, polyline, lineMetrics)`, `setEncodedPolyline`, `addLayer(LayerJson)`,
   `insertLayerBefore`, `removeLayer`, `setLayerVisibility`. Поверх — тонкие типизированные хелперы
   `LineLayer`, `FillLayer`, `SymbolLayer`, `CircleLayer` с `paint`/`layout` как `Map<String, Object?>` (Mapbox Style
   Spec), без собственной модели выражений.
3. Изображения: `addImage(id, Uint8List png)`, `addSvgImage(id, String svg, SizeDp)`, `removeImage`; маркеры ссылаются на
   `imageId`.
4. Готовые рецепты в фасаде: `drawRoute(encodedPolyline)` (source + line layer), `drawPolygon`, `drawCircle`
   (поле `steps`, как в legacy `CircleSource`, считается на Dart-стороне).
5. Кластеризация: реализовать на Dart (grid/supercluster-подобная агрегация по текущим `bounds` и `zoom`, пересчёт на
   `onCameraIdle`) как opt-in `VkMapClusterManager`; если вендор подтвердит нативную — заменить.
6. Тесты: JSON-сериализация слоёв, генерация круга, кластеризатор на синтетических точках.

### Критерии готовности

- Пример «маршрут + полигон + кастомная иконка + кластеры» работает на обеих платформах.
- В `docs/platform-matrix.md` явно отмечено, что кластеризация — Dart-реализация.

---

## 11. Этап 7 — `vk_maps_api`: REST-клиент на чистом Dart

**Приоритет:** P1.
**Сложность:** L.
**Зависимость:** этап 1. Не зависит от нативных этапов — параллельная ветка работ.
**Статус:** не начат.

### Задачи

1. `VkMapsApiClient(apiKey, baseUrl = 'https://maps.vk.com/api', http.Client?)`; `api_key` — query-параметр; общая
   обработка ошибок (`status_code`/`status`/`error_code`/`error` у routing; пустой `results` у поиска — не ошибка);
   `VkMapsApiException`; таймауты; учёт лимита 50 rps не реализуем, только документируем.
2. Поиск и геокодинг: `suggest(q, fields, types, location, radius, adminLevel, limit, lang)`,
   `places(q, fields, types, location, radius, limit, isocode, lang)`, `search(q | LatLon | ref, ...)` с
   разделением на `geocode`/`reverseGeocode`/`lookup(ref)`. Модели `AddressDetails`, `Entrance`, `GeoResult` с
   `geometry` как GeoJSON `Map`; `pin` → `LatLon` с переворотом `[lon, lat]`.
3. Маршрутизация: `directions(DirectionsRequest)` (locations с `type`/`heading`, costing `auto/truck/pedestrian/bicycle/taxi`,
   `costingOptions` типизированные по режиму, `units`, `language`, `directionsType`, `avoidLocations`, `dateTime`,
   `alternates`, `completeness`), `optimalRoute`, `distanceMatrix`, `isochrones` (contours time/distance, `polygons`,
   `generalize`, `showLocations` → GeoJSON). `ManeuverType` — enum 0…38. Модели `Trip`, `Leg`, `Maneuver`, `Edge`.
4. `decodePolyline(String, {precision = 6})` → `List<LatLon>` и `encodePolyline` (для elevation по polyline);
   тест на примере из документации.
5. Дополнительные сервисы: `elevation(locations | polyline, range, resampleDistance, heightPrecision)` — POST с полем
   `json`, `null` высоты; `ip2geo(ip?)` (`geo_id`); `timezone(LatLon, timestamp?)`; `postcode(q, fields, addresses, isocode)`.
6. Статическая карта: `StaticMapUrlBuilder` (GET: `latlon|bbox`, `zoom` 0…17, `width/height` 32…1024, `pins`, `style`,
   `padding`, `scale` 1|2) и `staticMapPng(StaticMapRequest)` (POST с `features`, `features-style`, кастомные иконки
   по URL ≤ 512 KB, HTTPS).
7. Тесты: `MockClient` с фикстурами из документации (`documents/research/rest_search_geocoding_pages_dump.txt` и
   примеры ответов routing), проверка сериализации запросов и всех расхождений из раздела 1 п. 7. Опциональный
   live-тест против `demo.maps.vk.com` за флагом `--dart-define=VK_MAPS_LIVE=1`.

### Критерии готовности

- Покрыты все 14 REST-сервисов из документации; каждый метод имеет фикстурный тест.
- Пакет не зависит от Flutter (`dart test` проходит без `flutter`); `dart pub publish --dry-run` чист.

---

## 12. Этап 8 — example-приложение и живая проверка

**Приоритет:** P0.
**Сложность:** L.
**Зависимость:** этапы 3–7.
**Статус:** не начат.

### Задачи

1. `packages/vk_maps_flutter/example`: экраны «Карта» (камера, стиль, маркеры, режимы, controls), «Маршрут»
   (`vk_maps_api.directions` → `drawRoute`), «Поиск» (`suggest` → `search(ref)` → маркер), «Изохроны», «Статическая
   карта». Ключ через `--dart-define=VK_MAPS_API_KEY`, `geolocator` для позиции пользователя.
2. `integration_test/` с `integrationDriver()`: карта создана, событие `mapShown` получено, `flyTo` изменил камеру,
   маркер добавлен и удалён, стиль переключён; запуск `make example-live-check` на Android и iOS.
3. Чек-лист живой проверки в `docs/live-verification-plan.md` по образцу `apptracer_flutter` (таблица «Проверка /
   Платформа / Результат / Дата»): рендер, жесты, память при 3 картах, поворот, background, offline-кэш, потеря сети,
   неверный ключ (какая ошибка приходит), тайлы `tileDidFail`.
4. Результаты — в `docs/status.md`; нерешённое — в `docs/questions-for-vendor.md`.

### Критерии готовности

- Все строки чек-листа заполнены датой и результатом для Android и iOS.
- Нет открытых крашей и утечек; известные ограничения перечислены в README.

---

## 13. Этап 9 — документация и публикация 0.1.0

**Приоритет:** P1.
**Сложность:** M.
**Зависимость:** этап 8.
**Статус:** не начат.

### Задачи

1. README пакета `vk_maps_flutter` (страница pub.dev, по-русски + `README.en.md`): быстрый старт Android/iOS
   (Maven-репозиторий и `pickFirsts` в `build.gradle` приложения, `Podfile`, минимальные версии), получение ключа,
   пример карты, пример REST, «если карта не появилась», ссылка на EULA SDK.
2. `docs/publishing.md`: порядок `platform_interface → api → android → ios → vk_maps_flutter`, чек-лист (changelog,
   версия, dry-run, `topics`, отсутствие секретов в архиве). В pubspec каждого пакета — `repository`,
   `issue_tracker`, `topics`; если в example останется демо-ключ, объявить его в `false_secrets` (как в
   `google_maps_flutter`), а не прятать.
3. `docs/platform-matrix.md` финальный: версии SDK, minSdk/iOS, что «только одна платформа», что на Dart.
4. Публикация `0.1.0` всех пяти пакетов; git-тег `v0.1.0`; ограничения ниже `1.0.0` до закрытия `docs/status.md`.

### Критерии готовности

- `pub.dev` показывает пять пакетов с зелёным анализом; example собирается с опубликованными версиями без
  `pubspec_overrides.yaml`.

---

## 14. Рекомендуемая последовательность задач

| № | Задача | Приоритет | Сложность | Зависимость |
| --- | --- | --- | --- | --- |
| 1 | Ключ, письмо вендору, проверка артефактов, разбор DocC в `docs/native-api-surface.md` | P0 | M | — |
| 2 | Скелет монорепо, `tool/`, `Makefile`, CI | P0 | M | 1 |
| 3 | Модели и Pigeon-контракт в `platform_interface` | P0 | L | 2 |
| 4 | iOS-реализация (CocoaPods + SPM) | P0 | XL | 3 |
| 5 | Android-реализация (KGP, матрица AGP×KGP×Gradle×JDK) | P0 | XL | 3, ответ вендора по Maven |
| 6 | Dart-фасад: виджет, контроллер, события, маркеры | P0 | L | 3 (живая проверка — 4 или 5) |
| 7 | `vk_maps_api`: поиск и геокодинг, polyline | P1 | M | 2 |
| 8 | `vk_maps_api`: маршрутизация, изохроны, матрица | P1 | M | 7 |
| 9 | `vk_maps_api`: elevation, ip2geo, timezone, postcode, static map | P1 | S | 7 |
| 10 | Стили, источники, слои, изображения, рецепты, кластеры на Dart | P1 | L | 6 |
| 11 | Example, интеграционные тесты, живая проверка | P0 | L | 4–10 |
| 12 | Документация и публикация 0.1.0 | P1 | M | 11 |

iOS (4) идёт раньше Android (5), потому что iOS-артефакты доступны уже сейчас, а Android заблокирован до ответа
вендора. Задачи 7–9 можно вести параллельно с 3–6 — это чистый Dart без устройств.

---

## 15. Общие проверки после каждого этапа

```shell
make format
make analyze        # flutter analyze --fatal-infos во всех пакетах
make test
make check          # + dart pub publish --dry-run
```

Дополнительно:

- `make gen` после правок `pigeons/*.dart`; сгенерированные файлы в diff проверять глазами;
- после нативных правок — `make example-android` / `make example-ios` на устройстве, не только на симуляторе;
- изменение версии SDK — отдельный коммит с записью в `docs/platform-matrix.md` и `CHANGELOG.md`;
- ни один пакет не тянет `api_key` в исходники и тесты.

---

## 16. Итоговые критерии плана

- Приложение на Flutter показывает карту VK Карт на Android и iOS через нативный SDK одной строкой `VkMap(...)`.
- Камера, маркеры, стили, GeoJSON/polyline-слои, изображения, режим следования и события покрыты Dart-API и
  проверены вживую на обеих платформах.
- Все REST-сервисы VK Карт доступны из чистого Dart с типизированными моделями и фикстурными тестами.
- Пять пакетов опубликованы на pub.dev, CI зелёный, документация по-русски и по-английски.
- Известные ограничения (нет web, нет нативной кластеризации, доступность Android-артефактов) зафиксированы явно.

---

## 17. Вне рамок плана

- Web-реализация через JS SDK `mmr-gl` — отдельный план после 0.1.0 (Mapbox GL JS-подобный API, `package:web`).
- macOS/desktop (SDK заявляет macOS 12+, Flutter-мост не проверялся).
- Поддержка legacy WebView-SDK (`ru.mail.maps:mapkit`, `MapsSDK` 1.1.x): бинарники недоступны, ветка мёртвая.
- Собственная типизированная модель Mapbox Style Spec (выражения, все свойства слоёв) — только `Map<String, Object?>`.
- Офлайн-карты и управление кэшем сверх параметров `setup` (`cacheDir`, `maxCacheSizeBytes`, `cacheFileTTL`).
- Навигационный движок (`RouteEngineCore`, `Escort`) — фреймворки есть в дистрибутиве, публичного API нет.
- Реализация клиентского rate-limiter для 50 rps.

---

## 18. Прогресс

- [ ] Этап 0 — доступы, артефакты, решение по SDK
- [ ] Этап 1 — скелет монорепозитория
- [ ] Этап 2 — `platform_interface` и Pigeon-контракт
- [ ] Этап 3 — Android
- [ ] Этап 4 — iOS
- [ ] Этап 5 — Dart-фасад
- [ ] Этап 6 — стили, источники, слои, изображения
- [ ] Этап 7 — `vk_maps_api`
- [ ] Этап 8 — example и живая проверка
- [ ] Этап 9 — документация и публикация 0.1.0

---

**Последнее обновление:** 8 сентября 2026 — план составлен по итогам чтения 45 страниц документации VK Карт и DocC
нативного SDK; зафиксировано решение строить обёртку на нативных пакетах (`VKMapsSDK`, `com.vk.maps:maps-native-sdk`)
по их документации, а не на legacy WebView-SDK и не на сторонних плагинах. Уточнено: выкладка VK переехала с
Artifactory на Nexus (`nexus-external.vkteam.ru`), Android-артефакты в публичной части не найдены. Добавлены
обязательные пункты про SPM (iOS) и KGP (Android), а также раздел 3 — что заимствуем у `yandex_maps_mapkit` и
`google_maps_flutter`.
