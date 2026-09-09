# Сверка с JavaScript SDK

JavaScript SDK VK Карт — форк Mapbox GL JS, и его документация описывает
поверхность карты подробнее, чем документация мобильных SDK: 111 методов
объекта `Map` и 48 событий. Мы используем её и как эталон полноты Dart-API,
и как описание платформы: с 9 сентября 2026 web — поддерживаемая платформа
плагина (решение Р-10), а `MMR GL JS` — то, на чём работает
`vk_maps_mapkit_web`.

Проверено 8 сентября 2026 по страницам `methods-a-h`, `methods-i-r`,
`methods-s-z`, `map/events`; 9 сентября 2026 сверено со сборкой
`mmr-gl.js` 0.2.43 (решение Р-11).

Таблицы ниже отвечают на вопрос «есть ли это в Dart-API плагина», а не «есть
ли это в web-SDK»: на web доступно всё, что перечислено в первой таблице, а
неподдержанное неподдержано во всём плагине — чаще всего потому, что этого
нет в мобильных SDK.

## Есть в плагине

| Возможность JS SDK | В плагине |
| --- | --- |
| `flyTo`, `easeTo`, `jumpTo`, `panTo` | `controller.animateCamera`, `controller.moveCamera` |
| `fitBounds` | `controller.fitBounds` |
| `zoomIn`, `zoomOut`, `zoomTo`, `setZoom` | `controller.zoomBy`, `VkCameraOptions.zoom` |
| `setBearing`, `setPitch`, `setCenter`, `setPadding` | `VkCameraOptions` |
| `getCenter`, `getZoom`, `getBearing`, `getPitch` | `controller.getCameraPosition` |
| `getBounds` | `controller.getVisibleBounds` (только iOS) |
| `unproject` | `controller.coordinateForScreenPoint` (только iOS) |
| `setMinZoom`, `setMaxZoom` | `VkMapConfiguration.minZoom` / `maxZoom` |
| `addSource`, `removeSource` | `controller.addGeoJsonSource`, `removeSource` |
| `addLayer`, `removeLayer`, `moveLayer` | `controller.addLayer` (с `beforeLayerId`), `removeLayer` |
| `setLayoutProperty` (видимость) | `controller.setLayerVisibility` |
| `addImage`, `removeImage` | `controller.addStyleImage`, `removeStyleImage` |
| `setStyle` | параметр `style` виджета |
| `dragPan`, `scrollZoom`, `dragRotate` | флаги жестов виджета |
| события `click`, `contextmenu` | `onTap`, `onLongTap` |
| события `move`, `moveend`, `zoom*` | `onCameraMove`, `onCameraIdle` |
| события `error` | `onError` |
| события `load`, `styledata` | `VkMapShownEvent`, `VkStyleAppliedEvent` |

## Нет и не планируется

| Возможность JS SDK | Почему нет |
| --- | --- |
| `getCanvas`, `getContainer`, `getCanvasContainer` | web-специфика: во Flutter карта живёт в platform view |
| `webglcontextlost`, `webglcontextrestored` | web-специфика |
| `showTileBoundaries`, `showCollisionBoxes`, `showPadding`, `showTerrainWireframe` | отладочные флаги движка; в мобильных SDK им соответствует `setDebugOption`, наружу не выносим |
| `setTerrain`, `setLight`, `setFreeCameraOptions` | нет в мобильных SDK |
| `mouseenter`, `mouseleave`, `mousemove`, `wheel` и прочие мышиные события | на мобильных платформах их нет |
| `addControl`, `removeControl` | контролы на мобильных — свойства карты (компас, кнопки зума), а не отдельные объекты; на web плагин сам собирает `NavigationControl`, `GeolocateControl` и `LogoControl` по этим свойствам |

## Нет, но стоит добавить

| Возможность JS SDK | Что нужно |
| --- | --- |
| `queryRenderedFeatures` | в нативном iOS SDK есть `featuresInRect`; на Android аналога в документации нет |
| `setFeatureState`, `getFeatureState` | на iOS есть выбор объектов (`selectMapFeature`), на Android — нет |
| `setPaintProperty`, `setLayoutProperty` для произвольных свойств | сейчас слой можно только пересоздать |
| `project` | на web уже работает (`controller.screenPointForCoordinate`), в мобильных SDK обратной проекции нет |
| `setMaxBounds` | ограничение области перемещения камеры |
| `resetNorth`, `snapToNorth` | делается через `VkCameraOptions(bearing: 0)`, но отдельный метод удобнее |

Список неподдержанного — не список недоработок: большая часть отсутствует в
самих мобильных SDK. Строки из последней таблицы имеет смысл превратить в
задачи после ответа вендора по Android.

## Чего в документации нет, а в сборке есть

Найдено при реализации web-пакета 9 сентября 2026; подробности — решение
Р-11 в [`design-decisions.md`](design-decisions.md).

| В сборке `mmr-gl.js` 0.2.43 | Как используется |
| --- | --- |
| опция карты `mmrglLogo` и `logoPosition` | логотип VK и его угол |
| `mmrgl.LogoControl` | перестановка логотипа после создания карты |
| событие `style.load` | один сигнал на собранный стиль вместо потока `styledata` |
| `attributionControl` по умолчанию `false` | документация обещает `true` |
| `mmrgl.supported()` отсутствует | проверка поддержки браузера пропускается |
