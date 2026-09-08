# Справочные материалы, собранные 8 сентября 2026

| Файл | Что это | Откуда |
| --- | --- | --- |
| `native_sdk_ios_docc_articles.md` | Статьи DocC актуального нативного SDK `MapsNativeSDK` (setup, камера, маркеры, стили, события) | `maps-mailru/vk-maps-distribution`, `MapsNativeSDK.doccarchive` |
| `native_sdk_ios_docc_symbols.md` | Список символов/сигнатур `MapsNativeSDK` | там же |
| `native_sdk_ios_distribution_readme.md` | Подключение SDK через SPM и CocoaPods | README `vk-maps-distribution` |
| `legacy_sdk_ios_readme.md` | README legacy `MapsSDK` 1.1.48 (WebView-поколение, описано на dev.vk.ru) | `maps-mailru/maps-sdk-ios` |
| `legacy_sdk_ios_changelog.md` | CHANGELOG legacy `MapsSDK` | там же |
| `rest_search_geocoding_pages_dump.txt` | Таблицы параметров и полные примеры JSON страниц suggest, places, geocoding, ip2geo, timezone, postcode | `dev.vk.ru/ru/vkmaps` |

## `dev_vk_ru/` — снимок документации VK Карт

37 страниц `dev.vk.ru/ru/vkmaps`, снятых 8 сентября 2026 скриптом [`../../tool/fetch_docs.py`](../../tool/fetch_docs.py).
Структура каталогов повторяет пути URL, источник каждой страницы указан в шапке файла. Разделы: общая информация и
API-ключ, JavaScript SDK (включая полные списки методов и событий `Map`), мобильные SDK Android и iOS, статичная
карта и стили, маршрутизация, поиск и геокодирование, дополнительные сервисы.

Обновить снимок: `python3 tool/fetch_docs.py documents/research/dev_vk_ru <url>…`. Сайт отдаёт серверный рендер
только не-браузерному `User-Agent`, поэтому скрипт представляется как `curl` — с UA Chrome приходит пустая
SPA-оболочка.
