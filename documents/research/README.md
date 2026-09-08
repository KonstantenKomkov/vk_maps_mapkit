# Справочные материалы, собранные 8 сентября 2026

| Файл | Что это | Откуда |
| --- | --- | --- |
| `native_sdk_ios_docc_articles.md` | Статьи DocC актуального нативного SDK `MapsNativeSDK` (setup, камера, маркеры, стили, события) | `maps-mailru/vk-maps-distribution`, `MapsNativeSDK.doccarchive` |
| `native_sdk_ios_docc_symbols.md` | Список символов/сигнатур `MapsNativeSDK` | там же |
| `native_sdk_ios_distribution_readme.md` | Подключение SDK через SPM и CocoaPods | README `vk-maps-distribution` |
| `legacy_sdk_ios_readme.md` | README legacy `MapsSDK` 1.1.48 (WebView-поколение, описано на dev.vk.ru) | `maps-mailru/maps-sdk-ios` |
| `legacy_sdk_ios_changelog.md` | CHANGELOG legacy `MapsSDK` | там же |
| `rest_search_geocoding_pages_dump.txt` | Таблицы параметров и полные примеры JSON страниц suggest, places, geocoding, ip2geo, timezone, postcode | `dev.vk.ru/ru/vkmaps` |

Исходники снятого с публикации плагина `flutter_vk_maps` 0.3.4666 (метаданные указывают на команду VK Карт, но
издатель на pub.dev не верифицирован) (Pigeon-контракт, Kotlin/Swift мост)
в репозиторий не копировались — лицензия EULA VK. Получить для справки: `dart pub cache add flutter_vk_maps --version 0.3.4666`.
