<!-- Источник: https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/sources -->
<!-- Снято: 2026-09-08 -->

# Sources (источники)

## GeoJSONSource

Источник (`source`), содержащий `GeoJSON`.

Путь до файла в библиотеке: `src/source/geojson_source.js`

#### Пример

```javascript
// download by url
map.addSource('some id', {
 type: 'geojson',
 data: 'https://d2ad6b4ur7yvpq.cloudfront.net/naturalearth-3.3.0/ne_10m_ports.geojson'
}); 

// set manualaly
map.addSource('some id', {
 type: 'geojson',
 data: {
 "type": "FeatureCollection",
 "features": [{
 "type": "Feature",
 "properties": {},
 "geometry": {
 "type": "Point",
 "coordinates": [
                    -76.53063297271729,
 39.18174077994108
                ]
            }
        }]
    }
});

// update source data
map.getSource('some id').setData({
 "type": "FeatureCollection",
 "features": [{
 "type": "Feature",
 "properties": { "name": "Null Island" },
 "geometry": {
 "type": "Point",
 "coordinates": [ 0, 0 ]
        }
    }]
});
```

### Методы

### getClusterChildren(clusterId, callback)

Для кластеризованных источников (`sources`) извлекает дочерние элементы данного кластера на следующем уровне масштабирования (в виде массива объектов `GeoJSON`).

Параметры:

- `clusterId:number` — идентификатор кластера;
- `callback:function<Array<GeoJSONFeature>>` — функция (`callback`), которая будет вызвана при извлечении объектов `( (error, features) => { ... } )`.

### getClusterExpansionZoom(clusterId, callback)

Для кластеризованных источников (`source`) выбирается масштаб, при котором данный кластер расширяется.

Параметры:

- `clusterId:number` — идентификатор кластера;
- `callback:function<number>` — функция (`callback`), которая будет вызвана при получении масштаба (`zoom`) `( (error, features) => { ... } )`.

### getClusterLeaves(clusterId, limit, offset, callback)

Для кластеризованных источников (`source`) извлекает исходные точки, принадлежащие кластеру (в виде массива объектов `GeoJSON`).

Параметры:

- `clusterId:number` — идентификатор кластера;
- `limit:number` — максимальное количество фич (`features`);
- `offset:number` — количество фич (`features`), которые нужно пропустить (например, для разбиения на страницы — `pagination`);
- `callback:function<Array<GeoJSONFeature>>` — функция (`callback`), которая будет вызвана при извлечении объектов `( (error, features) => { ... } )`.

#### Пример

```javascript
// Retrieve cluster leaves on click
map.on('click', 'clusters', function(e) {
 var features = map.queryRenderedFeatures(e.point, {
 layers: ['clusters']
  });

 var clusterId = features[0].properties.cluster_id;
 var pointCount = features[0].properties.point_count;
 var clusterSource = map.getSource('clusters');

  clusterSource.getClusterLeaves(clusterId, pointCount, 0, function(error, features) {
 // Print cluster leaves in the console
 console.log('Cluster leaves:', error, features);
  })
});
```

### setData(data)

Устанавливает данные `GeoJSON` и перерисовывает (`re-renders`) карту.

Параметр метода — `data:(Object|string)`. `GeoJSON` или URL-адрес к нему. Последнее предпочтительнее, если файл большой.

## VideoSource

Источник данных, содержащий видео.

Путь до файла в библиотеке: `src/source/video_source.js`

#### Пример

```javascript
// add to map
map.addSource('some id', {
 type: 'video',
 url: [
 'path-to-video.mp4',
 'path-to-video.webm'
    ],
 coordinates: [
        [-76.54, 39.18],
        [-76.52, 39.18],
        [-76.52, 39.17],
        [-76.54, 39.17]
    ]
});

// update
var mySource = map.getSource('some id');
mySource.setCoordinates([
    [-76.54335737228394, 39.18579907229748],
    [-76.52803659439087, 39.1838364847587],
    [-76.5295386314392, 39.17683392507606],
    [-76.54520273208618, 39.17876344106642]
]);

map.removeSource('some id');  // remove
```

### Методы

### getVideo()

Возвращает HTML-видео.

### pause()

Позволяет приостановить воспроизведение видео.

### play()

Позволяет продолжить воспроизведение видео.

### setCoordinates()

Устанавливает координаты видео и перерисовывает (`re-render`) карту.

## ImageSource

Источник данных изображения.

Путь до файла в библиотеке: `src/source/image_source.js`

#### Пример

```javascript
// add to map
map.addSource('some id', {
 type: 'image',
 url: 'foo.png',
 coordinates: [
        [-76.54, 39.18],
        [-76.52, 39.18],
        [-76.52, 39.17],
        [-76.54, 39.17]
    ]
});

// update coordinates
var mySource = map.getSource('some id');
mySource.setCoordinates([
    [-76.54335737228394, 39.18579907229748],
    [-76.52803659439087, 39.1838364847587],
    [-76.5295386314392, 39.17683392507606],
    [-76.54520273208618, 39.17876344106642]
]);

// update url and coordinates simultaneously
mySource.updateImage({
 url: 'bar.png',
 coordinates: [
        [-76.54335737228394, 39.18579907229748],
        [-76.52803659439087, 39.1838364847587],
        [-76.5295386314392, 39.17683392507606],
        [-76.54520273208618, 39.17876344106642]
    ]
})

map.removeSource('some id');  // remove
```

### Методы

### setCoordinates(coordinates)

Устанавливает координаты изображения и перерисовывает (`re-render`) карту.

### updateImage(options)

Обновляет URL-адрес изображения и при необходимости координаты.

Чтобы избежать мерцания изображения, установите свойство `raster-fade-duration` равным `0`.

Параметры:

- `url:string` — URL изображения;
- `coordinates:Array<Array<number>>` — четыре координаты, представленные в виде массивов чисел долготы и широты, определяющие углы изображения. Координаты начинаются в верхнем левом углу изображения и идут по часовой стрелке.

## CanvasSource

Источник данных, содержит контент HTML-холста (HTML canvas).

Путь до файла в библиотеке: `src/source/canvas_source.js`

#### Пример

```javascript
// add to map
map.addSource('some id', {
 type: 'canvas',
 canvas: 'idOfMyHTMLCanvas',
 animate: true,
 coordinates: [
        [-76.54, 39.18],
        [-76.52, 39.18],
        [-76.52, 39.17],
        [-76.54, 39.17]
    ]
});

// update
var mySource = map.getSource('some id');
mySource.setCoordinates([
    [-76.54335737228394, 39.18579907229748],
    [-76.52803659439087, 39.1838364847587],
    [-76.5295386314392, 39.17683392507606],
    [-76.54520273208618, 39.17876344106642]
]);

map.removeSource('some id');  // remove
```

### Методы

### getCanvas()

Возвращает HTML канвас.

### pause()

Отключает анимацию. Карта будет отображать статическую копию изображения холста.

### play()

Включает анимацию. Карта будет интерактивная.

### setCoordinates(coordinates

Устанавливает координаты канваса и перерисовывает (`re-render`) карту.

Параметр метода — `coordinates:Array<Array<number>>`. Четыре координаты, представленные в виде массивов чисел долготы и широты, определяющие углы канваса. Координаты начинаются в верхнем левом углу канваса и идут по часовой стрелке.

## CanvasSourceOptions

Параметры добавления типа источника канваса на карту.

Путь до файла в библиотеке: `src/source/canvas_source.js`

### Параметры

- `type:string` — тип источника, должен быть равен `canvas`;
- `canvas:(string | HTMLCanvasElement)` — источник холста, из которого можно считывать пиксели. Это может быть строка, представляющая идентификатор элемента canvas, или сам `HTMLCanvasElement`.
- `coordinates:Array<Array<number>>` — четыре координаты, обозначающие, где разместить углы канваса, задаются в парах [долгота, широта];
- `animate:boolean` — является ли источник канваса анимированным. Если канвас статичен (то есть пиксели не нужно перечитывать на каждом кадре), `animate` следует установить в `false` для повышения производительности.
