<!-- Источник: https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/events -->
<!-- Снято: 2026-09-08 -->

# Events (события)

## Evented

Методы добавления и удаления лисенеров (listeners).

Путь до файла в библиотеке: `src/util/evented.js`

### Методы

### off(type, listener)

Удаляет ранее зарегистрированный лисенер (`listener`).

Параметры:

- `type:string` — тип событий;
- `listener:function` — функция лисенер (`listener`).

### on(type, listener)

Регистрирует новый лисенер (`listener`).

Параметры:

- `type:string` — тип событий;
- `listener:function` — функция лисенер (`listener`).

### once(type, listener)

Добавляет лисенер (`listener`), который будет вызываться только один раз для указанного типа события.

Параметры:

- `type:string` — тип событий;
- `listener:function` — функция лисенер (`listener`).

## MapMouseEvent

События, связанные с мышью.

Путь до файла в библиотеке: `src/ui/events.js`

### Пример

```javascript
// The `click` event is an example of a `MapMouseEvent`.
// Set up an event listener on the map.
map.on('click', function(e) {
 // The event object (e) contains information like the
 // coordinates of the point on the map that was clicked.
 console.log('A click event has occurred at ' + e.lngLat);
});
```

### Свойства

| Название | Описание |
| --- | --- |
| `lngLat` | Координаты курсора на карте. |
| `originalEvent` | Событие DOM, вызвавшее событие карты. |
| `point` | Пиксельные координаты курсора мыши отсчитываются относительно экрана. Отсчёт начинается из левого верхнего угла (координата `0,0`). |
| `preventDefault()` | Предотвращает вызов по умолчанию следующих поведений:
 • событие `mousedown`, обрабатывающееся в `DragPanHandler`;
 • событие `mousedown`, обрабатывающееся в `DragRotateHandler`;
 • событие `mousedown`, обрабатывающееся в `BoxZoomHandler`;
 • событие `dblclick`, обрабатывающееся в `DoubleClickZoomHandler`. |
| `target` | Объект карты, который запустил событие. |
| `type` | Тип события:
 • `Map.event:mousedown`;
 • `Map.event:mouseup`;
 • `Map.event:click`;
 • `Map.event:dblclick`;
 • `Map.event:mousemove`;
 • `Map.event:mouseover`;
 • `Map.event:mouseenter`;
 • `Map.event:mouseleave`;
 • `Map.event:mouseout`;
 • `Map.event:contextmenu`. |

## MapTouchEvent

События, связанные с касаниями (`touch`).

Путь до файла в библиотеке: `src/ui/events.js`

### Свойства

| Название | Описание |
| --- | --- |
| `lngLat` | Координаты касания на карте. |
| `lngLats` | Массив координат, соответствующих касаниям на карте. |
| `originalEvent` | Событие DOM, вызвавшее событие карты. |
| `point` | Пиксельные координаты курсора мыши отсчитываются относительно экрана. Отсчёт начинается из левого верхнего угла (координата `0,0`). |
| `points` | Массив координат пикселей, соответствующих касаниям. |
| `preventDefault()` | Предотвращает вызов по умолчанию следующих поведений:
 • событие `touchstart`, обрабатывающееся в `DragPanHandler`;
 • событие `touchstart`, обрабатывающееся в `TouchZoomRotateHandler`. |
| `target` | Объект карты, который запустил событие. |
| `type` | Тип события. |

## MapBoxZoomEvent

`BoxZoomHandler` используется для генерации событий `boxzoom`.

Путь до файла в библиотеке: `src/ui/events.js`

### Параметры

- `originalEvent:MouseEvent` — DOM-событие, вызвавшее событие `boxzoom`. Принимает значения: `MouseEvent` или `KeyboardEvent`;
- `type:string` — тип события `boxzoom`. Принимает значения: `boxzoomstart`, `boxzoomend` или `boxzoomcancel`;
- `target:Map` — экземпляр карты, вызвавший событие.

## MapDataEvent

Объект `MapDataEvent` создается вместе с событиями `Map.event:data` и `Map.event:dataloading`. Возможные значения для типов данных являются:

- `source` — данные, не связанные с тайлами, но связанны с любым источником;
- `style` — стиль карты.

### Параметры

- `type:string` — тип события;
- `dataType:string` — тип данных, которые изменились. Принимает значения: `source` , `style`;
- `isSourceLoaded:boolean` — `true`, если событие имеет тип данных `source` и источник (`source`) не имеет нерешенных сетевых запросов (`outstanding network requests`);
- `source:Object` — объект типа `source`;
- `sourceDataType:string` — включается, если событие имеет тип данных `source` и событие сообщает, что внутренние данные были получены или изменены. Возможными значениями яляются `metadata`, `content` и `visibility`;
- `tile:Object` — загружаемый или изменяемый тайл, если событие имеет тип данных `source` и связано с загрузкой тайла;
- `coord:Coordinate` — координата тайла, если событие имеет тип данных `source` и событие связано с загрузкой тайла.

Путь до файла в библиотеке: `src/ui/events.js`

### Пример

```javascript
// The sourcedata event is an example of MapDataEvent.
// Set up an event listener on the map.
map.on('sourcedata', function(e) {
 if (e.isSourceLoaded) {
 // Do something when the source has finished loading
  }
});
```

## MapWheelEvent

События, связанные с `wheel`.

Путь до файла в библиотеке: `src/ui/events.js`

### Свойства

| Название | Описание |
| --- | --- |
| `orignalEvent` | Событие DOM, вызвавшее событие map. |
| `preventDefault()` | Предотвращает последующую обработку события. Вызов этого метода предотвратит поведение `ScrollZoomHandler`. |
| `target` | Объект карты, который запустил событие. |
| `type` | Тип события. |
