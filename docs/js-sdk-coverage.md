# Сверка с JavaScript SDK

JavaScript SDK VK Карт — форк Mapbox GL JS, и его документация описывает
поверхность карты подробнее, чем документация мобильных SDK: 111 методов
объекта `Map` и 48 событий. Мы используем её как эталон полноты: ниже
сверка, что из этого есть в Dart-API плагина, а чего нет и почему.

Проверено 8 сентября 2026 по страницам `methods-a-h`, `methods-i-r`,
`methods-s-z`, `map/events`.

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
| `addControl`, `removeControl` | контролы на мобильных — свойства карты (компас, кнопки зума), а не отдельные объекты |

## Нет, но стоит добавить

| Возможность JS SDK | Что нужно |
| --- | --- |
| `queryRenderedFeatures` | в нативном iOS SDK есть `featuresInRect`; на Android аналога в документации нет |
| `setFeatureState`, `getFeatureState` | на iOS есть выбор объектов (`selectMapFeature`), на Android — нет |
| `setPaintProperty`, `setLayoutProperty` для произвольных свойств | сейчас слой можно только пересоздать |
| `project` | обратной проекции нет ни в одном мобильном SDK |
| `setMaxBounds` | ограничение области перемещения камеры |
| `resetNorth`, `snapToNorth` | делается через `VkCameraOptions(bearing: 0)`, но отдельный метод удобнее |

Список неподдержанного — не список недоработок: большая часть отсутствует в
самих мобильных SDK. Строки из последней таблицы имеет смысл превратить в
задачи после ответа вендора по Android.
