<!-- Источник: https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/map/methods-i-r -->
<!-- Снято: 2026-09-08 -->

# Методы объекта `Map` (i...r)

← Методы объекта Map (a...h)         Методы объекта Map (s...z) →

## isMoving()

Возвращает `true`, если карта перемещается, масштабируется, вращается или наклоняется из-за анимации камеры или жеста пользователя.

```javascript
var isMoving = map.isMoving();
```

## isRotating()

Возвращает `true`, если карта вращается из-за анимации камеры или жеста пользователя.

```javascript
map.isRotating();
```

## isSourceLoaded(id)

Возвращает логическое значение, указывающее, загружен ли источник (`source`). Возвращает `true`, если источник с заданным идентификатором в стиле карты не имеет сетевых запросов, в противном случае `false`.

Параметр метода — `id:string`. Идентификатор источника (`source`), подлежащего проверке.

```javascript
var sourceLoaded = map.isSourceLoaded('bathymetry-data');
```

## isStyleLoaded()

Возвращает логическое значение, указывающее, полностью ли загружен стиль карты.

```javascript
var styleLoadStatus = map.isStyleLoaded();
```

## isZooming()

Возвращает `true`, если карта масштабируется из-за анимации камеры или жеста пользователя.

```javascript
var isZooming = map.isZooming();
```

## jumpTo(options, eventData?)

Изменяет любую комбинацию `center`, `zoom`, `bearing` и `pitch` без анимированного перехода. Карта сохранит свои текущие значения для любых деталей, которые не были указаны в опциях.

Параметры:

- `options:``CameraOptions` — объект опции;
- `eventData` — дополнительные свойства, добавляемые к объектам событий, инициируемых этим методом.

```javascript
// jump to coordinates at current zoom
map.jumpTo({center: [0, 0]});
// jump with zoom, pitch, and bearing options
map.jumpTo({
 center: [0, 0],
 zoom: 8,
 pitch: 45,
 bearing: 90
});
```

## keyboard

KeyboardHandler карты, который позволяет пользователю масштабировать, поворачивать и перемещать карту с помощью сочетаний клавиш. Более подробную информацию и примеры использования клавиатуры можно найти в разделе KeyboardHandler.

## listImages()

Возвращает массив строк, содержащий идентификаторы всех изображений, доступных в данный момент на карте. Сюда входят как изображения из исходного спрайта стиля, так и любые изображения, добавленные с помощью метода `Map#addImage`.

```javascript
var allImages = map.listImages();
```

## loaded()

Возвращает логическое значение — признак полной загрузки карты. Значение `false`, если стиль еще не полностью загружен или, если произошли изменения в источниках или стиле, которые еще не загружены полностью.

## loadImage(url, callback)

Загружает изображение с внешнего URL-адреса для использования с `Map#addImage`. Внешние домены должны поддерживать `CORS`.

Параметры:

- `url:string` — URL-адрес файла изображения. Файл изображения должен быть в формате `png`, `webp` или `jpg`;
- `callback:Function` — ожидание `callback(error, data)`. Вызывается при загрузке изображения или с аргументом `error`, если есть ошибка.

```javascript
// Load an image from an external URL.
map.loadImage('http://placekitten.com/50/50', function(error, image) {
if (error) throw error;
 // Add the loaded image to the style's sprite with the ID 'kitten'.
  map.addImage('kitten', image);
});
```

## moveLayer(id, beforeId?)

Перемещает слой в другое z-положение.

Параметры:

- `id:string` — идентификатор слоя для перемещения;
- `beforeId:string` — идентификатор слоя, до которого будет вставлен новый слой. При просмотре карты слой `id` появится под слоем `BeforeID`. Если параметр `BeforeID` опущен, то слой будет добавлен в конец массива слоев и появится над всеми другими слоями на карте.

```javascript
// Move a layer with ID 'polygon' before the layer with ID 'country-label'. The `polygon` layer will appear beneath the `country-label` layer on the map.
map.moveLayer('polygon', 'country-label');
```

## off(type, listener)

Удаляет лисенер событий, ранее добавленный с `Map#on`.

Параметры:

- `type:string` — тип события, ранее использовавшийся для установки лисенера (`listener`);
- `listener:Function` — функция, ранее установленная в качестве лисенера (`listener`).

## off(type, layerId, listener)

Удаляет лисенер событий для конкретных событий слоя, ранее добавленных с помощью `Map#on`.
Параметры:

- `type:string` — тип события, который был использован ранее для установки лисенера (`listener`);
- `layerId:string` — идентификатор слоя, который был использован ранее для установки лисенера (`listener`);
- `listener:Function` — функция, ранее установленная в качестве лисенера (`listener`).

## on(type, layerId, listener)

Добавляет лисенер (`listener`) для событий заданного типа, необязательно ограниченного объектами в заданном слое стиля.

Параметры:

- `type:string` — тип события для лисенера (`listener`). События, совместимые с необязательным параметром `layerId`, запускаются, когда курсор входит в видимую часть указанного слоя снаружи или за пределами холста карты.
- `layerId:string` (необязательный) — идентификатор слоя стиля. Событие будет вызвано только в том случае, если его местоположение находится в пределах видимого объекта в этом слое. Событие будет иметь свойство `features`, содержащее массив соответствующих объектов. Если `layerId` не указан, событие не будет иметь свойства `features`. Обратите внимание, что многие типы событий несовместимы с дополнительным параметром `layerId`;
- `listener:Function` — функция, вызываемая при запуске события.

## type

| Событие | Совместимость с layerId |
| --- | --- |
| `mousedown` | yes |
| `mouseup` | yes |
| `mouseover` | yes |
| `mouseout` | yes |
| `mousemove` | yes |
| `mouseenter` | yes (required) |
| `mouseleave` | yes (required) |
| `click` | yes |
| `dbclick` | yes |
| `contextmenu` | yes |
| `touchstart` | yes |
| `touchend` | yes |
| `touchcancel` | yes |
| `wheel` | no |
| `resize` | no |
| `remove` | no |
| `touchmove` | no |
| `movestart` | no |
| `move` | no |
| `moveend` | no |
| `dragstart` | no |
| `drag` | no |
| `dragend` | no |
| `zoomstart` | no |
| `zoom` | no |
| `zoomend` | no |
| `rotatestart` | no |
| `rotate` | no |
| `rotateend` | no |
| `pitchstart` | no |
| `pitch` | no |
| `pitchend` | no |
| `boxzoomstart` | no |
| `boxzoomend` | no |
| `boxzoomcancel` | no |
| `webglcontextlost` | no |
| `webglcontextrestored` | no |
| `load` | no |
| `render` | no |
| `idle` | no |
| `error` | no |
| `data` | no |
| `styledata` | no |
| `sourcedata` | no |
| `dataloading` | no |
| `styledataloading` | no |
| `sourcedataloading` | no |
| `styleimagemissing` | no |

```javascript
// Set an event listener that will fire
// when the map has finished loading
map.on('load', function() {
 // Once the map has finished loading,
 // add a new layer
    map.addLayer({
 id: 'points-of-interest',
 source: {
 type: 'vector',
 url: 'path-to-source'
        },
 'source-layer': 'poi_label',
 type: 'circle',
 paint: {
 // Style Specification paint properties
        },
 layout: {
 // Style Specification layout properties
        }
    });
});
```

```javascript
// Set an event listener that will fire
// when a feature on the countries layer of the map is clicked
map.on('click', 'countries', function(e) {
 new mmrgl.Popup()
        .setLngLat(e.lngLat)
        .setHTML(`Country name: ${e.features[0].properties.name}`)
        .addTo(map);
});
```

## once(type, listener)

Добавляет лисенер (`listener`), который будет вызываться только один раз для указанного типа события.

Параметры:

- `layerId:string` (необязательный) — идентификатор слоя стиля. Событие будет вызвано только в том случае, если его местоположение находится в пределах видимого объекта в этом слое. Событие будет иметь свойство `features`, содержащее массив соответствующих объектов. Если `layerId` не указан, событие не будет иметь свойства `features`. Обратите внимание, что многие типы событий несовместимы с дополнительным параметром `layerId`.
- `listener:Function` — функция, вызываемая при запуске события.

## once(type, layerId, listener)

Добавляет лисенер (`listener`), который будет вызываться только один раз для указанного типа события, происходящего на объектах в указанном слое стиля.

Параметры:

- `type:string` — тип события для лисенера (`listener`). Доступные значения: `mousedown`, `mouseup`, `click`, `dblclick`, `mousemove`, `mouseenter`, `mouseleave`, `mouseover`, `mouseout`, `contextmenu`, `touchstart`, `touchend` или `touchcancel`. События `mouseenter` и `mouseover` запускаются, когда курсор входит в видимую часть указанного слоя снаружи этого слоя или за пределами холста карты. События `mouseleave` и `mouseout` запускаются, когда курсор покидает видимую часть указанного слоя или покидает холст карты;
- `layerId:string` — идентификатор слоя стиля. Только события, расположение которых находится в пределах видимого объекта в этом слое, вызовут лисенер (`listener`). Событие будет иметь свойство `features`, содержащее массив соответствующих объектов;
- `listener:Function` — функция, вызываемая при запуске события.

## panBy(offset, options?, eventData?)

Перемещает карту по заданному смещению.

Параметры:

- `offset:``PointLike` — координаты `x` и `y` для перемещения карты;
- `options:``AnimationOptions` — объект опций;
- `eventData` — дополнительные свойства. Могут добавлены к объектам тех событий, которые были инициированы методом `panBy`.

## panTo(lnglat, options?, eventData?)

Перемещает карту в указанное место с анимированным переходом.

Параметры:

- `lnglat:``LngLatLike` — место для перемещения карты;
- `options:``AnimationOptions` — объект опций;
- `eventData` — дополнительные свойства. Могут добавлены к объектам тех событий, которые были инициированы методом `panTo`.

```javascript
map.panTo([-74, 38]);
// Specify that the panTo animation should last 5000 milliseconds.
map.panTo([-74, 38], {duration: 5000});
```

## project(lnglat)

Возвращает точку, представляющую пиксельные координаты относительно контейнера карты, соответствующие указанному географическому местоположению. Когда карта наклонена и `lnglat` полностью находится за камерой, нет никаких пиксельных координат, соответствующих этому местоположению. В этом случае компоненты `x` и `y` возвращаемой точки имеют значение `Number.MAX_VALUE`.

Параметр метода — `lnglat:``LngLatLike`. Географическое положение проекта.

```javascript
var coordinate = [-122.420679, 37.772537];
var point = map.project(coordinate);
```

## queryRenderedFeatures(geometry? options?)

Возвращает массив объектов `GeoJSON Feature`, представляющих видимые объекты, удовлетворяющие параметрам запроса.

Параметры:

- `geometry`: `PointLike` | `Array<``PointLike``>` — геометрия области запроса в пикселях: либо одна точка, либо нижняя левая и верхняя правая точки, описывающие ограничивающую рамку, где начало координат находится в верхнем левом углу. Пропуск этого параметра (т. е. вызов `Map#queryRenderedFeatures` с нулевыми аргументами или только с аргументом `options`) эквивалентен передаче ограничивающего прямоугольника, охватывающего весь видовой экран карты;
- `options:Object` — объект опции.

## options (метод queryRenderedFeatures)

| Название | Описание |
| --- | --- |
| `layers:Array<string>` | Массив идентификаторов слоя стиля для проверки запроса. Будут возвращены только объекты внутри этих слоев. Если этот параметр не определен, то будут проверены все слои. |
| `filter:Array` | Фильтр для ограничения результатов запроса. |
| `validate:boolean` | Следует ли проверить, соответствует ли спецификации стиля. Отключение проверки — это оптимизация производительности, которую следует использовать только в том случае, если вы предварительно проверили значения, которые будете передавать этой функции. |

Возвращает: `Array<Object>` — массив объектов `GeoJSON`. Значение свойств каждого возвращаемого объекта содержит свойства его исходного объекта. Для источников `GeoJSON` поддерживаются только строковые и числовые значения свойств (т. е. значения `null`, `Array` и `Object` не поддерживаются). Каждый объект включает в себя свойства слоя верхнего уровня, источника и исходного слоя. Свойство `layer` — это объект, представляющий слой стиля, к которому принадлежит объект. Свойства `layout` и `paint` в этом объекте содержат значения, которые полностью оцениваются для данного уровня масштабирования и объекта. Включены только те функции, которые в данный момент визуализируются. Некоторые функции не будут включены, например:

- объекты из слоев, свойство видимости которых равно `none`;
- объекты из слоев, диапазон масштабирования которых исключает текущий уровень масштабирования;
- функции символов, которые были скрыты из-за столкновения текста или значков.

Включаются объекты из всех других слоев, с учетом тех, которые могут не иметь визуализируемый результат. Самый верхний визуализированный объект появляется первым в возвращаемом массиве. Последующие объекты сортируются по убыванию z-порядка. Объекты, которые визуализируются несколько раз (из-за обертывания по антимеридиану при низких уровнях масштабирования), возвращаются только один раз.

Поскольку объекты берутся из векторных тайлов или данных `GeoJSON`, которые преобразуются в тайлы, геометрия объектов может быть разделена или дублирована через границы тайлов, и в результате объекты могут появляться несколько раз в результатах запроса. Например, предположим, что существует шоссе, проходящее через ограничивающий прямоугольник запроса. Результатом запроса будут те части шоссе, которые лежат внутри тайлов карты, покрывающих ограничивающий прямоугольник, даже если шоссе простирается на другие тайлы, и часть шоссе внутри каждой плитки карты будет возвращена как отдельный объект. Точно так же точечный объект вблизи границы тайлов может появиться в нескольких тайлах из-за буферизации тайла.

```javascript
// Find all features at a point
var features = map.queryRenderedFeatures(
  [20, 35],
  { layers: ['my-layer-name'] }
);
```

```javascript
// Find all features within a static bounding box
var features = map.queryRenderedFeatures(
  [[10, 20], [30, 50]],
  { layers: ['my-layer-name'] }
);
```

```javascript
// Find all features within a bounding box around a point
var width = 10;
var height = 20;
var features = map.queryRenderedFeatures([
  [point.x - width / 2, point.y - height / 2],
  [point.x + width / 2, point.y + height / 2]
], { layers: ['my-layer-name'] });
```

```javascript
// Query all rendered features from a single layer
var features = map.queryRenderedFeatures({ layers: ['my-layer-name'] });
```

## querySourceFeatures(sourceId, parameters?)

Возвращает массив объектов `GeoJSON Feature`, представляющих объекты в пределах указанной векторной плитки или источника `GeoJSON`, которые удовлетворяют параметрам запроса.

Параметры:

- `sourceId:string` — идентификатор векторных тайлов или источника `GeoJSON` для запроса;
- `parameters` — объект параметров.

## parameters

| Название | Описание |
| --- | --- |
| `sourceLayer:string` | Имя исходного слоя для запроса. Для источников векторных тайлов этот параметр является обязательным. Для источников GeoJSON он игнорируется. |
| `filter:Array` | Фильтр для ограничения результатов запроса. |
| `validate:boolean` | Отключение проверки — это оптимизация производительности, которую следует использовать только в том случае, если вы предварительно проверили значения, которые будете передавать этой функции. |

Возвращает `Array<Object>` — массив объектов `GeoJSON`. В отличие от `Map#queryRenderedFeatures` эта функция возвращает все объекты, соответствующие параметрам запроса, независимо от того, отображаются они текущим стилем (т. е. видимыми) или нет.

Домен запроса включает в себя все загруженные в данный момент векторные тайлы и исходные тайлы `GeoJSON`. Эта функция не проверяет тайлы за пределами видимого в данный момент окна просмотра. Поскольку объекты берутся из тайлов векторных данных или данных `GeoJSON`, которые преобразуются в тайлы внутренне, геометрия объектов может быть разделена или дублирована через границы тайлов, и в результате объекты могут появляться несколько раз в результатах запроса.

Например, предположим, что существует шоссе, проходящее через ограничивающий прямоугольник запроса. Результатом запроса будут те части шоссе, которые лежат внутри тайлов карты, покрывающих ограничивающий прямоугольник, даже если шоссе распространяется на другие тайлы, и часть шоссе внутри каждого тайла карты будет возвращена как отдельный объект. Точно так же точечный объект вблизи границы тайла может появиться в нескольких тайлах из-за буферизации тайлов.

```javascript
// Find all features in one source layer in a vector source
var features = map.querySourceFeatures('your-source-id', {
 sourceLayer: 'your-source-layer'
});
```

## remove()

Очищает и освобождает все внутренние ресурсы, связанные с картой. Сюда входят элементы DOM, привязки событий, веб-воркеры и ресурсы `WebGL`. Используйте этот метод, когда вы закончите использовать карту и хотите убедиться, что она больше не потребляет ресурсы браузера. После этого вы не должны вызывать никаких других методов на карте.

## removeControl(control)

Удаляет элемент управления с карты.

Параметр метода — `control:iControl`. Удаляемый `IControl`.

```javascript
// Define a new navigation control.
var navigation = new mmrgl.NavigationControl();
// Add zoom and rotation controls to the map.
map.addControl(navigation);
// Remove zoom and rotation controls from the map.
map.removeControl(navigation);
```

## removeFeatureState(feature, key)

Удаляет состояние объекта, возвращая ему поведение по умолчанию. Если указан только `feature.source`, он удалит состояние для всех объектов из этого источника. Если также указано `feature.id`, то он удалит все ключи для состояния этого объекта. Если также указан ключ, он удаляет только этот ключ из состояния этого объекта. Объекты определяются через `feature.id`, который может быть любым числом или строкой.

Параметры:

- `feature:Object` — идентификатор места удаления состояния. Это может быть источник, объект или определенный ключ объекта. Объекты, возвращаемые из `Map#queryRenderedFeatures` или обработчиков событий, могут использоваться в качестве идентификаторов объектов;
- `key:string` (необязательный) — ключ в состоянии объекта для сброса.

## feature

| Название | Описание |
| --- | --- |
| `id:number` | `string` |
| `source:string` | Идентификатор вектора или источника `GeoJSON` для объекта. |
| `sourceLayer:string` (необязательный) | Для источников векторных тайлов требуется `sourceLayer`. |

```javascript
// Reset the entire state object for all features
// in the `my-source` source
map.removeFeatureState({
 source: 'my-source'
});
```

```javascript
// When the mouse leaves the `my-layer` layer,
// reset the entire state object for the
// feature under the mouse
map.on('mouseleave', 'my-layer', function(e) {
  map.removeFeatureState({
 source: 'my-source',
 sourceLayer: 'my-source-layer',
 id: e.features[0].id
  });
});
```

```javascript
// When the mouse leaves the `my-layer` layer,
// reset only the `hover` key-value pair in the
// state for the feature under the mouse
map.on('mouseleave', 'my-layer', function(e) {
  map.removeFeatureState({
 source: 'my-source',
 sourceLayer: 'my-source-layer',
 id: e.features[0].id
  }, 'hover');
});
```

## removeImage(id)

Удаляет изображение из стиля. Это может быть изображение из оригинального спрайта стиля или любые изображения, добавленные с помощью метода `Map#addImage`.

Параметр метода — `id:string`. Идентификатор изображения.

```javascript
// If an image with the ID 'cat' exists in
// the style's sprite, remove it.
if (map.hasImage('cat')) map.removeImage('cat');
```

## removeLayer(id)

Удаляет слой с заданным идентификатором из стиля карты. Если такого слоя не существует, запускается событие ошибки.

Параметр метода — `id:string`. Идентификатор слоя для удаления.

```javascript
// If a layer with ID 'state-data' exists, remove it.
if (map.getLayer('state-data')) map.removeLayer('state-data');
```

## removeSource(id)

Удаляет источник из стиля карты.
Параметр метода — `id:string`. Идентификатор источника для удаления.

```javascript
map.removeSource('bathymetry-data');
```

## repaint

Возвращает и задает логическое значение, указывающее, будет ли карта непрерывно перерисовываться. Эта информация полезна для анализа производительности.

## resetNorth(options?, eventData?)

Поворачивает карту с анимированным переходом так, чтобы север был вверху (пеленг 0°).

Параметры:

- `options:``AnimationOptions` — объект опций;
- `eventData` — дополнительные свойства. Могут быть добавлены к объектам событий, которые инициированы методом `resetNorth`.

## resetNorthPitch(options?, eventData?)

Поворачивает и наклоняет карту так, чтобы север был вверх (азимут 0°), а тангаж — 0°, с анимированным переходом.

Параметры:

- `options:``AnimationOptions` — объект опций;
- `eventData` — дополнительные свойства. Могут быть добавлены к объектам событий, которые инициированы методом `resetNorthPitch`.

## resize(eventData?)

Изменяет размер карты в соответствии с размерами её контейнерного элемента. Проверяет, изменился ли размер контейнера карты, и обновляет карту, если она изменилась. Этот метод должен быть вызван после того, как контейнер карты будет изменён программно или когда карта будет показана после первоначального скрытия с помощью CSS.

Параметр метода — `eventData:Object`. Дополнительные свойства, передаваемые событиям `movestart`, `move`, `resize` и `moveend`, которые запускаются в результате изменения размера. Это может быть полезно для дифференциации источника события (например, инициированных пользователем или программно инициированных событий).

```javascript
// Resize the map when the map container is shown
// after being initially hidden with CSS.
var mapDiv = document.getElementById('map');
if (mapDiv.style.visibility === true) map.resize();
```

## rotateTo(bearing, options?, eventData?)

Поворачивает карту на заданный пеленг с анимированным переходом. Пеленг — это направление компаса «вверх». Например, пеленг 90° ориентирует карту так, что восток находится вверху.

Параметры:

- `bearing:number` — желаемый пеленг;
- `options:``AnimationOptions` — объект опций;
- `eventData` — дополнительные свойства. Могут быть добавлены к объектам событий, которые инициированы данным методом.

← Методы объекта Map (a...h)         Методы объекта Map (s...z) →
