<!-- Источник: https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/map/methods-a-h -->
<!-- Снято: 2026-09-08 -->

# Методы объекта `Map` (a...h)

Методы объекта Map (i...r) →

## addControl(control, position?)

Добавляет IControl на карту, вызывая `control.onAdd(this`).

Параметры:

- `control:iControl` — добавляемый `IControl`;
- `position:string` — позиция на карте (`top-left`, `top-right`, `bottom-left`, `bottom-right`). По умолчанию — `top-right`.

## addImage(id, image, options)

Добавляет изображение в стиль. Это изображение может быть отображено на карте, как и любой другой значок в спрайте, используя идентификатор изображения с `icon-image`, `background-pattern`, `fill-pattern` или `line-pattern`. Событие `Map.event:error` будет вызвано, если в спрайте недостаточно места для добавления этого изображения.

Параметры:

- `id:string` — ID изображения;
- `image:HTMLImageElement` | `ImageBitmap` | `ImageData` | `{width: number, height: number`, `data: (Uint8Array | Uint8ClampedArray)}` | `StyleImageInterface` — изображение в виде `HTMLImageElement`, `ImageData`, `ImageBitmap` или объекта со свойствами `width`, `height` и `data` в том же формате, что и `ImageData`.

## options (метод addImage)

| Название | Описание |
| --- | --- |
| `pixelRatio` | Отношение пикселей в изображении к физическим пикселям на экране. |
| `sdf` | Следует ли интерпретировать изображение как SDF-изображение. |
| `stretchX [[x1, x2], ...]` | Если `icon-text-fit` используется в слое с этим изображением, эта опция определяет часть (или части) изображения, которая может быть растянута горизонтально. |
| `stretchY [[y1, y2], ...]` | Если `icon-text-fit` используется в слое с этим изображением, эта опция определяет часть (или части) изображения, которая может быть растянута вертикально. |
| `content [x1, y1, x2, y2]` | Если `icon-text-fit` используется в слое с этим изображением, эта опция определяет часть изображения, которая может быть покрыта содержимым в текстового поля. |

```javascript
// If the style's sprite does not already contain an image with ID 'cat',
// add the image 'cat-icon.png' to the style's sprite with the ID 'cat'.
map.loadImage('https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Cat_silhouette.svg/400px-Cat_silhouette.svg.png', function(error, image) {
 if (error) throw error;
 if (!map.hasImage('cat')) map.addImage('cat', image);
});

// Add a stretchable image that can be used with `icon-text-fit`
// In this example, the image is 600px wide by 400px high.
map.loadImage('https://upload.wikimedia.org/wikipedia/commons/8/89/Black_and_White_Boxed_%28bordered%29.png', function(error, image) {
 if (error) throw error;
 if (!map.hasImage('border-image')) {
        map.addImage('border-image', image, {
 content: [16, 16, 300, 384], // place text over left half of image, avoiding the 16px border
 stretchX: [[16, 584]], // stretch everything horizontally except the 16px border
 stretchY: [[16, 384]], // stretch everything vertically except the 16px border
        });
    }
});
```

## addLayer(layer, beforedId?)

Добавляет слой стиля к стилю карты. Слой определяет, как будут стилизованы данные из указанного источника.

Параметры:

- `layer` ((`Object` | `CustomLayerInterface`)) — добавляемый слой, соответствует либо спецификации стиля, либо спецификации CustomLayerInterface.
- `beforeId:string` — вставки нового слоя до существующего слоя по идентификатору, в результате чего новый слой визуально появляется под существующим слоем. Если этот аргумент не указан, слой будет добавлен в конец массива слоев и визуально появится над всеми остальными слоями.

## Описание объекта Layer (метод addLayer)

| Название | Описание |
| --- | --- |
| `id:string` | Уникальный идентификатор слоя. |
| `type:string` | Тип слоя (например, заливка или символ). Может быть кастомным. Дополнительные сведения см. в разделе CustomLayerInterface. |
| `source:(string` | `object)` |
| `sourceLayer` (необязательный) | Имя слоя в указанном `layer.source`, который будет использоваться для слоя стиля. Это применимо только для векторных тайлов и требуется, если `layer.source` имеет тип `vector`. |
| `filter:array` (необязательный) | Выражение, задающее условия для объектов. Отображаются только те объекты, которые соответствуют фильтру. Спецификация стиля содержит дополнительную информацию об ограничениях параметра фильтра и полный список доступных выражений. Если фильтр не предусмотрен, будут показаны все объекты. |
| `layout.object` (необязательный) | Свойства слоя. Доступные свойства зависят от типа слоя (`layer.type`). Если layout не задан, будут использоваться значения по умолчанию. |
| `maxzoom:number` (необязательный) | Максимальный уровень масштабирования для слоя. При уровнях масштабирования, равных или превышающих `maxzoom`, слой будет скрыт. Значение может быть любым числом от `0` до `24` (включительно). Если `maxzoom` не указан, слой будет виден на всех уровнях масштабирования, для которых доступны тайлы. |
| `minzoom:number` (необязательный) | Минимальный уровень масштабирования для слоя. При уровнях масштабирования меньше, чем `minzoom`, слой будет скрыт. Значение может быть любым числом от `0` до `24` (включительно). Если `minzoom` не предусмотрен, слой будет виден на всех уровнях масштабирования, для которых доступны тайлы. |
| `metadata:object` (необязательный) | Произвольные свойства, полезные для отслеживания со слоем, но не влияющие на рендеринг. |
| `renderingMode:string` | Применимо только для слоев с типом `custom`. Дополнительные сведения см. в разделе CustomLayerInterface. |

```javascript
// Add a circle layer with a vector source
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
```

```javascript
// Define a source before using it to create a new layer
map.addSource('state-data', {
 type: 'geojson',
 data: 'path/to/data.geojson'
});

map.addLayer({
 id: 'states',
 // References the GeoJSON source defined above
 // and does not require a `source-layer`
 source: 'state-data',
 type: 'symbol',
 layout: {
 // Set the label content to the
 // feature's `name` property
        text-field: ['get', 'name']
    }
});
```

```javascript
// Add a new symbol layer before an existing layer
map.addLayer({
 id: 'states',
 // References a source that's already been defined
 source: 'state-data',
 type: 'symbol',
 layout: {
 // Set the label content to the
 // feature's `name` property
        text-field: ['get', 'name']
    }
 // Add the layer before the existing `cities` layer
}, 'cities');
```

## addSource(id, source)

Добавляет источник в стиль карты.
Параметры:

- `id:string` — идентификатор добавляемого источника. Не должно конфликтовать с существующими источниками;
- `source:object` — исходный объект, соответствующий спецификации источника или CanvasSourceOptions.

#### Пример

```javascript
map.addSource('my-data', {
 type: 'vector',
 url: 'path-to-source'
});
```

```javascript
map.addSource('my-data', {
 "type": "geojson",
 "data": {
 "type": "Feature",
 "geometry": {
 "type": "Point",
 "coordinates": [-77.0323, 38.9131]
        },
 "properties": {
 "title": "title",
 "marker-symbol": "monument"
        }
    }
});
```

## areTilesLoaded()

Возвращает логическое значение, указывающее загружены ли все плитки в окне просмотра из всех источников стиля.

```javascript
var tilesLoaded = map.areTilesLoaded();
```

## boxZoom

BoxZoomHandler карты, который реализует масштабирование с помощью жеста перетаскивания с нажатой клавишей Shift. Более подробную информацию и примеры использования `boxZoom` можно найти в разделе BoxZoomHandler.

## cameraForBounds(bounds, options?)

Параметры:

- `bounds:` `LngLatBoundsLike` — вычисляет центр границ в окне, используя самый высокий уровень масштабирования вплоть до `Map#getMaxZoom()`, который помещается в окне. LngLatBounds представляет собой коробку, которая всегда выровнена по оси с пеленгом `0`;
- `options:Object` — объект опции.

## options (метод cameraForBounds)

| Название | Описание |
| --- | --- |
| `padding:(number` | `PaddingOptions``)` |
| `bearing:number` | Желаемый пеленг карты в конце анимации, задается в градусах. |
| `offset:``PointLike` | Центр заданных границ относительно центра карты, измеренный в пикселях. |
| `maxZoom:number` | Максимальный уровень масштабирования, допускаемый при переходе камеры в заданные границы. |

#### Пример

```javascript
var bbox = [[-79, 43], [-73, 45]];
 var newCameraTransform = map.cameraForBounds(bbox, {
 padding: {top: 10, bottom:25, left: 15, right: 5}
});
```

## doubleClickZoom

DoubleClickZoomHandler карты, который позволяет пользователю увеличивать масштаб двойным щелчком мыши. Более подробную информацию и примеры использования `doubleClickZoom` можно найти в разделе DoubleClickZoomHandler.

## dragPan

DragPanHandler карты, который реализует перетаскивание карты с помощью мыши или сенсорного жеста. Более подробную информацию и примеры использования `dragPan` вы найдете в разделе DragPanHandler.

## dragRotate

DragRotateHandler карты, который реализует поворот карты при перетаскивании правой кнопкой мыши или нажатой клавишей управления. Более подробную информацию и примеры использования `dragRotate` можно найти в разделе DragRotateHandler.

## easeTo(options, eventData?)

Изменяет любую комбинацию `center`, `zoom`, `bearing`, `pitch` и `padding` с анимированным переходом между старыми и новыми значениями. Карта сохранит свои текущие значения для любых деталей, не указанных в опциях.

Если пользователь в настройках доступности своей операционной системы отключил анимации (`reduced motion`), то переход произойдет мгновенно. Этого можно избежать, передав `essential: true` в объект `options`.

Параметры:

- `options:Object` — параметры, описывающие пункт назначения и анимацию перехода. Принимает CameraOptions и AnimationOptions;
- `eventData` — дополнительные свойства, добавляемые к объектам событий, инициируемых этим методом.

## fitBounds(bounds, options?, eventData?)

Перемещает и масштабирует карту так, чтобы она содержала видимую область в заданных географических границах. Эта функция также сбросит пеленг карты на `0`, если пеленг ненулевой. Если на карте заданы отступы, границы будут соответствовать вставке.

Параметры:

- `bounds:``LngLatBoundsLike` — центрирует эти границы в окне и использует самый высокий уровень масштабирования вплоть до `Map#getMaxZoom()`, который соответствует им в окне;
- `eventData` — дополнительные свойства, добавляемые к объектам событий, инициируемых этим методом;
- `options:Object` — опции поддерживают все свойства из AnimationOptions и CameraOptions в дополнение к полям ниже.

## options (метод fitBounds)

| Название | Описание |
| --- | --- |
| `padding:(number` | `PaddingOptions``)` |
| `linear:boolean` | Если `true`, то карта переходит с помощью `Map#easeTo`. Если `false`, то карта переходит с помощью `Map#flyTo`. См. эти функции и AnimationOptions для получения информации о доступных опциях. |
| `easing:function?` | Функция ослабления для анимированного перехода. См. раздел AnimationOptions . |
| `offset:``PointLike` | Центр заданных границ относительно центра карты, измеренный в пикселях. |
| `maxZoom:number` | Максимальный уровень масштабирования, допускаемый при переходе камеры в заданные границы. |

#### Пример

```javascript
var bbox = [[-79, 43], [-73, 45]];
map.fitBounds(bbox, {
 padding: {top: 10, bottom:25, left: 15, right: 5}
});
```

## fitScreenCoordinates(p0, p1, bearing, options?, eventData?)

Перемещает, поворачивает и масштабирует карту так, чтобы она соответствовала коробке, сделанной точками `p0` и `p1`, как только карта повернута к указанному пеленгу. Чтобы увеличить масштаб без поворота, передайте текущий пеленг карты.
Параметры:

- `p0:``PointLike` — первая точка на экране в пиксельных координатах;
- `p1:``PointLike` — вторая точка на экране в пиксельных координатах;
- `bearing:number` — желаемый пеленг карты в конце анимации, в градусах. Это значение игнорируется, если карта имеет ненулевой шаг;
- `eventData` — дополнительные свойства, добавляемые к объектам событий, инициируемых этим методом;

## options (метод fitScreenCoordinates)

| Название | Описание |
| --- | --- |
| `padding:(number` | `PaddingOptions``)` |
| `linear:boolean` | Если `true`, то карта переходит с помощью `Map#easeTo`. Если `false`, то карта переходит с помощью `Map#flyTo`. См. эти функции и AnimationOptions для получения информации о доступных опциях. |
| `easing:function?` | Функция ослабления для анимированного перехода. См. раздел AnimationOptions. |
| `offset:``PointLike` | Центр заданных границ относительно центра карты, измеренный в пикселях. |
| `maxZoom:number` | Максимальный уровень масштабирования, допускаемый при переходе камеры в заданные границы. |

#### Пример

```javascript
var p0 = [220, 400];
var p1 = [500, 900];
map.fitScreenCoordinates(p0, p1, map.getBearing(), {
 padding: {top: 10, bottom:25, left: 15, right: 5}
});
```

## flyTo(options, eventData?)

Изменяет любую комбинацию `center`, `zoom`, `bearing` и `pitch`, анимируя переход вдоль кривой, вызывающей передвижение. Анимация плавно включает в себя масштабирование и перемещение, чтобы помочь пользователю сохранять ориентацию даже после прохождения большого расстояния.

Анимация будет пропущена (поведение эквивалентно `jumpTo`), если пользователь включил функцию уменьшенной доступности движения (`reduced motion`) в своей операционной системе, если только параметры не включают `essential: true`.

## options (метод flyTo)

| Название | Описание |
| --- | --- |
| `curve:number``default: 1.42` | Масштабирование `curve`, которое будет происходить вдоль траектории движения. Высокое значение максимизирует масштабирование для преувеличенной анимации, в то время как низкое значение минимизирует масштабирование в результате эффект получается близким к `Map#easeTo`. `1.42` — это среднее значение, выбранное участниками исследования пользователей, обсуждаемого в van Wijk (2003). Значение `Math.pow(6, 0.25)` было бы эквивалентно среднеквадратичной средней скорости. Значение `1` будет производить круговое движение. |
| `minZoom:number` | Нулевой уровень масштабирования на пике траектории движения. Если указан параметр `options.curve`, то этот параметр игнорируется. |
| `speed:number``default: 1.2` | Средняя скорость анимации определяется по отношению к `options.curve`. Скорость `1.2` означает, что карта движется по траектории полета в `1.2` раза быстрее. `Screenful` — это видимый промежуток карты. Он не соответствует фиксированному физическому расстоянию, но изменяется в зависимости от уровня масштабирования. |
| `screenSpeed:number?` | Средняя скорость анимации измеряется в секундах экрана, предполагая линейную временную кривую. Если указан параметр `options.speed`, то этот параметр игнорируется. |
| `maxDuration:number?` | Максимальная продолжительность анимации, измеряемая в миллисекундах. Если длительность превышает максимальную продолжительность, она сбрасывается на `0`. |

`eventData` — дополнительные свойства, добавляемые к объектам событий, инициируемых этим методом.

```javascript
// fly with default options to null island
map.flyTo({center: [0, 0], zoom: 9});
// using flyTo options
map.flyTo({
 center: [0, 0],
 zoom: 9,
 speed: 0.2,
 curve: 1,
 easing(t) {
 return t;
  }
});
```

## getBearing()

Возвращает текущий пеленг карты. Пеленг — это направление компаса вверх. Например, пеленг `90°` ориентирует карту так, чтобы восток был сверху.

## getBounds()

Возвращает географические границы карты. Когда пеленг или тангаж ненулевой, видимая область не является прямоугольником, выровненным по оси, и в результате получается наименьшая граница, охватывающая видимую область. Если на карте заданы отступы, то возвращаемые границы относятся к вставке.

```javascript
var bounds = map.getBounds();
```

## getCanvas()

Возвращает элемент `<canvas>` карты.

## getCanvasContainer()

Возвращает HTML-элемент, содержащий элемент `<canvas>` карты. Если вы хотите добавить не GL оверлеи на карту, вы должны добавить их к этому элементу. Это элемент, к которому привязаны события для интерактивности карты (например, перемещение и масштабирование). Он будет получать события от дочерних элементов, таких как `<canvas>`, но не от элементов управления картой.

## getCenter()

Возвращает географическую центральную точку карты.

```javascript
// return a LngLat object such as {lng: 0, lat: 0}
var center = map.getCenter();
// access longitude and latitude values directly
var {longitude, latitude} = map.getCenter();
```

## getContainer()

Возвращает HTML-элемент, содержащий карту.

## getFeatureState(feature)

Возвращает состояние объекта. Состояние объекта — это набор определяемых пользователем пар ключ-значение, которые назначаются объекту во время выполнения. Фичи (`features`) определяются через `feature.id` атрибут, который может быть любым числом или строкой.

Чтобы получить доступ к значениям объекта для целей стилизации объекта, используйте фича-выражения.

Параметр метода — `feature:Object`. Идентификатор объекта. Объекты фичи, возвращаемые из `Map#queryRenderedFeatures` или обработчиков событий, могут использоваться в качестве идентификаторов объектов.

## options

| Название | Описание |
| --- | --- |
| `id:number` | `string` |
| `source:string` | Идентификатор вектора или источника `GeoJSON` для объекта. |
| `sourceLayer:string` (необязательный) | Для источников векторных тайлов требуется `sourceLayer`. |

```javascript
// When the mouse moves over the `my-layer` layer,
// get the feature state for the feature under the mouse
map.on('mousemove', 'my-layer', function(e) {
 if (e.features.length > 0) {
    map.getFeatureState({
 source: 'my-source',
 sourceLayer: 'my-source-layer',
 id: e.features[0].id
    });
  }
});
```

## getFilter(layerId)

Возвращает фильтр, примененный к указанному слою стиля.

## getFreeCameraOptions()

Возвращает положение и ориентацию объекта камеры.

## getLayer(id)

Возвращает слой с указанным идентификатором в стиле карты.
Параметр метода — `id:string`. Идентификатор слоя, который нужно получить.

```javascript
var stateDataLayer = map.getLayer('state-data');
```

## getLayoutProperty(layerId, name)

Возвращает значение свойства `layout` в указанном слое стиля.
Параметры:

- `layerId:string` — идентификатор слоя, из которого будет получено свойство `layout`;
- `name:string` — название свойства слоя, которое нужно получить.

## getLight()

Возвращает значение светового объекта.

## getMaxBounds()

Возвращает максимальные географические границы, к которым привязана карта, или `null`, если они не установлены.

```javascript
var maxBounds = map.getMaxBounds();
```

## getMaxPitch()

Возвращает максимально допустимый наклон карты.

## getMaxZoom()

Возвращает максимально допустимый уровень масштабирования карты.

```javascript
var maxZoom = map.getMaxZoom();
```

## getMinPitch()

Возвращает минимально допустимый шаг карты.

## getMinZoom()

Возвращает минимально допустимый уровень масштабирования карты.

```javascript
var minZoom = map.getMinZoom();
```

## getPadding()

Возвращает текущее отступы, примененные вокруг видового экрана карты.

## getPaintProperty(layerId, name)

Возвращает значение свойства `paint` в указанном слое стиля.
Параметры:

- `layerId:string` — идентификатор слоя, из которого будет получено свойство `paint`;
- `name:string` — имя свойства `paint`, которое нужно получить.

## getPitch()

Возвращает текущий наклон карты.

## getRenderWorldCopies()

Возвращает состояние `renderWorldCopies`. Если это `true`, то несколько копий мира будут отображаться бок о бок за пределами -180 и 180 градусов долготы. Если установлено значение `false`, то:

- когда карта будет увеличена настолько, что ни одно изображение мира не заполнит весь контейнер карты, за пределами 180 и -180 градусов долготы останется пустое пространство;
- объекты, пересекающие 180 и -180 градусов долготы, будут разрезаны на две части (одна будет находиться на правом краю карты, а другая — на левом) на каждом уровне масштабирования.

```javascript
var worldCopiesRendered = map.getRenderWorldCopies();
```

## getSource(id)

Возвращает источник с указанным идентификатором в стиле карты. Этот метод часто используется для обновления источника с использованием элементов экземпляра для соответствующего типа источника, определенного в источниках. Например, установка данных для источника `GeoJSON` или обновление URL-адреса и координат источника изображения.

Параметр метода — `id:string`. Идентификатор источника, который нужно получить.

```javascript
var sourceObject = map.getSource('points');
```

## getStyle()

Возвращает объект стиля карты, объект `JSON`, который может быть использован для воссоздания стиля карты.

```javascript
map.on('load', function() {
 var styleJson = map.getStyle();
});
```

## getTerrain()

Возвращает спецификацию `terrain` или `null`, если `terrain` не задан на карте.

## getZoom()

Возвращает текущий уровень масштабирования карты.

```javascript
map.getZoom();
```

## hasControl(control)

Проверяет, есть ли на карте элемент управления.

Параметр метода — `control:IControl`. `IControl` для проверки.

```javascript
// Define a new navigation control.
var navigation = new mmrgl.NavigationControl();
// Add zoom and rotation controls to the map.
map.addControl(navigation);
// Check that the navigation control exists on the map.
const added = map.hasControl(navigation);
// added === true
```

## hasImage(id)

Проверяет, существует ли в стиле изображение с определенным идентификатором. Проверяет как изображения в оригинальном спрайте стиля, так и любые изображения, добавленные с помощью метода `Map#addImage`.

Параметр метода — `id:string`. Идентификатор изображения.

```javascript
// Check if an image with the ID 'cat' exists in
// the style's sprite.
var catIconExists = map.hasImage('cat');
```

Методы объекта Map (i...r) →
