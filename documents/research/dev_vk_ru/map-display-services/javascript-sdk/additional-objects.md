<!-- Источник: https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/additional-objects -->
<!-- Снято: 2026-09-08 -->

# Описание дополнительных объектов карты

## AttributionControl

Элемент управления `AttributionControl` представляет информацию об атрибутах карты (копирайтинг и тд).

Путь до файла в библиотеке: `src/ui/control/attribution_control.js`

#### Параметры

- `compact:boolean` — если `true`, то всегда отображается в компактном виде, если `false`, то будет всегда в полный размер, по умолчанию это работает в зависимости от размера карты `(viewport < 640 ? compact : full)`;
- `customAttribution:string|Array<string>` — строка или строки для отображения в атрибутах карты.

#### Пример

```javascript
var map = new mmrgl.Map({attributionControl: false})
  .addControl(new mmrgl.AttributionControl({
 compact: true
   }));
```

## LngLatBoundsLike

Объект `LngLatBounds`, массив `LngLatLike` объектов в порядке `[sw, ne]` или массив чисел в порядке `[west, south, east, north]`.

Путь до файла в библиотеке: `src/geo/lng_lat_bound.js`

#### Пример

```javascript
var v1 = new mmrgl.LngLatBounds(
 new mmrgl.LngLat(-73.9876, 40.7661),
 new mmrgl.LngLat(-73.9397, 40.8002)
);
var v2 = new mmrgl.LngLatBounds([-73.9876, 40.7661], [-73.9397, 40.8002])
var v3 = [[-73.9876, 40.7661], [-73.9397, 40.8002]];
```
