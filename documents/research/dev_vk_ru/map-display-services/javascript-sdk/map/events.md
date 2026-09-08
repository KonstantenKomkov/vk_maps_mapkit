<!-- Источник: https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/map/events -->
<!-- Снято: 2026-09-08 -->

# События объекта `Map`

## boxzoomcancel

Срабатывает, когда пользователь отменяет взаимодействие «масштабирование коробки» или когда ограничивающий прямоугольник не соответствует минимальному порогу размера. См. BoxZoomHandler.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// the user cancels a "box zoom" interaction.
map.on('boxzoomcancel', function() {
 console.log('A boxzoomcancel event occurred.');
});
```

## boxzoomend

Срабатывает, когда заканчивается `box zoom`. См. BoxZoomHandler.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// just after a "box zoom" interaction ends.
map.on('boxzoomend', function() {
 console.log('A boxzoomend event occurred.');
});
```

## boxzoomstart

Срабатывает при запуске `box zoom`. См. BoxZoomHandler.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// just before a "box zoom" interaction starts.
map.on('boxzoomstart', function() {
 console.log('A boxzoomstart event occurred.');
});
```

## click

Срабатывает при нажатии.

Это событие совместимо с необязательным параметром `layerId`. Если `layerId` включен в качестве второго аргумента в `Map#on`, лисенер событий будет срабатывать только тогда, когда точка, которая нажата, содержит видимую часть указанного слоя.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener
map.on('click', function(e) {
 console.log('A click event has occurred at ' + e.lngLat);
});
```

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener for a specific layer
map.on('click', 'poi-label', function(e) {
 console.log('A click event has occurred on a visible portion of the poi-label layer at ' + e.lngLat);
});
```

## contextmenu

Срабатывает при нажатии правой кнопки мыши или клавиши контекстного меню внутри карты.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when the right mouse button is
// pressed within the map.
map.on('contextmenu', function() {
 console.log('A contextmenu event occurred.');
});
```

## data

Срабатывает при загрузке или изменении любых картографических данных.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when map data loads or changes.
map.on('data', function() {
 console.log('A data event occurred.');
});
```

## dataloading

Срабатывает, когда любые картографические данные (стиль, источник, плитка и т.д.) начинают загружаться или изменяться асинхронно. За всеми `dataloading` следует событие `data` или `error`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when any map data begins loading
// or changing asynchronously.
map.on('dataloading', function() {
 console.log('A dataloading event occurred.');
});
```

## dbclick

Срабатывает, когда нажимается дважды в одной и той же точке карты в быстрой последовательности.

Это событие совместимо с необязательным параметром `layerId`. Если `layerId` включен в качестве второго аргумента в `Map#on`, лисенер событий будет срабатывать только тогда, когда дважды щелкнутая точка содержит видимую часть указанного слоя.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener
map.on('dblclick', function(e) {
 console.log('A dblclick event has occurred at ' + e.lngLat);
});
```

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener for a specific layer
map.on('dblclick', 'poi-label', function(e) {
 console.log('A dblclick event has occurred on a visible portion of the poi-label layer at ' + e.lngLat);
});
```

## drag

Срабатывает неоднократно во время взаимодействия `drag to pan`. См. DragPanHandler.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// repeatedly during a `drag to pan` interaction.
map.on('drag', function() {
 console.log('A drag event occurred.');
});
```

## dragend

Срабатывает, когда заканчивается взаимодействие `drag to pan`. См. DragPanHandler.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when a `drag to pan` interaction ends.
map.on('dragend', function() {
 console.log('A dragend event occurred.');
});
```

## dragstart

Срабатывает, когда начинается взаимодействие `drag to pan`. См. DragPanHandler.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when a `drag to pan` interaction starts.
map.on('dragstart', function() {
 console.log('A dragstart event occurred.');
});
```

## error

Срабатывает при возникновении ошибки. Это основной механизм отчетности об ошибках `MMR GL JS`. Мы используем `event` вместо `throw`, чтобы лучше приспособиться к асинхронным операциям. Если лисенер не привязан к событию `error`, то ошибка будет выведена в консоль.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when an error occurs.
map.on('error', function() {
 console.log('A error event occurred.');
});
```

## idle

Срабатывает после последнего кадра, отрисованного до того, как карта перейдет в состояние простоя:

- Никаких переходов камеры не происходит;
- Все запрошенные в данный момент тайлы загружены;
- Все анимации затухания или перехода завершены.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// just before the map enters an "idle" state.
map.on('idle', function() {
 console.log('A idle event occurred.');
});
```

## load

Срабатывает сразу после того, как все необходимые ресурсы были загружены и произошел первый визуально полный рендеринг карты.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when the map has finished loading.
map.on('load', function() {
 console.log('A load event occurred.');
});
```

## mousedown

Срабатывает при нажатии внутри карты.

Это событие совместимо с необязательным параметром `layerId`. Если `layerId` включен в качестве второго аргумента в `Map#on`, лисенер событий будет срабатывать только при нажатии курсора, находясь внутри видимой части указанного слоя.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener
map.on('mousedown', function() {
 console.log('A mousedown event has occurred.');
});
```

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener for a specific layer
map.on('mousedown', 'poi-label', function() {
 console.log('A mousedown event has occurred on a visible portion of the poi-label layer.');
});
```

## mouseenter

Срабатывает, когда курсор входит в видимую часть указанного слоя снаружи этого слоя или за пределами холста карты.

Это событие можно прослушивать только тогда, когда `Map#on` включает в себя три аргумента, где второй аргумент указывает на нужный слой.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener
map.on('mouseenter', 'water', function() {
 console.log('A mouseenter event occurred on a visible portion of the water layer.');
});
```

## mouseleave

Срабатывает, когда курсор оставляет видимую часть указанного слоя или покидает холст карты.

Это событие можно прослушивать только тогда, когда `Map#on` включает в себя три аргумента, где второй аргумент указывает на нужный слой.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when the pointing device leaves
// a visible portion of the specified layer.
map.on('mouseleave', 'water', function() {
 console.log('A mouseleave event occurred.');
});
```

## mousemove

Срабатывает при перемещении курсора, когда курсор находится внутри карты. При перемещении курсора по карте событие будет срабатывать каждый раз, когда курсор меняет свое положение на карте.

Это событие совместимо с необязательным параметром `layerId`. Если `layerId` включен в качестве второго аргумента в `Map#on`, лисенер событий будет срабатывать только тогда, когда курсор находится внутри видимой части указанного слоя.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener
map.on('mousemove', function() {
 console.log('A mousemove event has occurred.');
});
```

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener for a specific layer
map.on('mousemove', 'poi-label', function() {
 console.log('A mousemove event has occurred on a visible portion of the poi-label layer.');
});
```

## mouseout

Срабатывает, когда курсор мыши покидает холст карты.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when the pointing device leave's
// the map's canvas.
map.on('mouseout', function() {
 console.log('A mouseout event occurred.');
});
```

## mouseover

Срабатывает, когда курсор мыши перемещается внутри карты. При перемещении курсора по веб-странице, содержащей карту, событие будет срабатывать каждый раз, когда оно входит в карту или любые дочерние элементы.

Это событие совместимо с необязательным параметром `layerId`. Если `layerId` включен в качестве второго аргумента в `Map#on`, лисенер событий будет срабатывать только при перемещении курсора внутри видимой части указанного слоя.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener
map.on('mouseover', function() {
 console.log('A mouseover event has occurred.');
});
```

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener for a specific layer
map.on('mouseover', 'poi-label', function() {
 console.log('A mouseover event has occurred on a visible portion of the poi-label layer.');
});
```

## mouseup

Срабатывает, когда курсор мыши высвобождается в пределах карты.

Это событие совместимо с необязательным параметром `layerId`. Если `layerId` включен в качестве второго аргумента в `Map#on`, прослушиватель событий будет срабатывать только тогда, когда курсор будет отпущен, находясь внутри видимой части указанного слоя.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener
map.on('mouseup', function() {
 console.log('A mouseup event has occurred.');
});
```

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener for a specific layer
map.on('mouseup', 'poi-label', function() {
 console.log('A mouseup event has occurred on a visible portion of the poi-label layer.');
});
```

## move

Многократно срабатывает во время анимированного перехода от одного вида к другому в результате взаимодействия с пользователем или таких методов, как `Map#flyTo`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// repeatedly during an animated transition.
map.on('move', function() {
 console.log('A move event occurred.');
});
```

## moveend

Срабатывает сразу после того, как карта завершает переход от одного вида к другому, в результате либо взаимодействия с пользователем, либо таких методов, как `Map#jumpTo`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// just after the map completes a transition.
map.on('moveend', function() {
 console.log('A moveend event occurred.');
});
```

## movestart

Срабатывает непосредственно перед тем, как карта начинает переход от одного вида к другому, в результате либо взаимодействия пользователя, либо таких методов, как `Map#jumpTo`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// just before the map begins a transition
// from one view to another.
map.on('movestart', function() {
 console.log('A movestart` event occurred.');
});
```

## pitch

Многократно срабатывает во время анимации тангажа (наклона) карты между одним состоянием и другим в результате взаимодействия пользователя или таких методов, как `Map#flyTo`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// repeatedly during a pitch (tilt) transition.
map.on('pitch', function() {
 console.log('A pitch event occurred.');
});
```

## pitchend

Срабатывает сразу же после того, как тангаж (наклон) карты заканчивается в результате взаимодействия с пользователем или таких методов, как `Map#flyTo`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// just after a pitch (tilt) transition ends.
map.on('pitchend', function() {
 console.log('A pitchend event occurred.');
});
```

## pitchstart

Срабатывает всякий раз, когда тангаж (наклон) карты начинает меняться в результате взаимодействия с пользователем или таких методов, как `Map#flyTo`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// just before a pitch (tilt) transition starts.
map.on('pitchstart', function() {
 console.log('A pitchstart event occurred.');
});
```

## remove

Срабатывает сразу после удаления карты с помощью `Map.event:remove`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// just after the map is removed.
map.on('remove', function() {
 console.log('A remove event occurred.');
});
```

## render

Срабатывает всякий раз, когда карта рисуется на экране, в результате:

- изменения положения карты, масштабирования, высоты тона или пеленга;
- изменения стиля карты;
- изменения источника `GeoJSON`;
- загрузки векторного тайла, файла `GeoJSON`, глифа или спрайта;

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// whenever the map is drawn to the screen.
map.on('render', function() {
 console.log('A render event occurred.');
});
```

## resize

Срабатывает сразу же после изменения размера карты.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// immediately after the map has been resized.
map.on('resize', function() {
 console.log('A resize event occurred.');
});
```

## rotate

Срабатывает неоднократно во время взаимодействия `drag to rotate`. См. раздел DragRotateHandler.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// repeatedly during `drag to rotate` interaction.
map.on('rotate', function() {
 console.log('A rotate event occurred.');
});
```

## rotateend

Срабатывает, когда заканчивается взаимодействие `drag to rotate`. См. раздел DragRotateHandler.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// just after a `drag to rotate` interaction ends.
map.on('rotateend', function() {
 console.log('A rotateend event occurred.');
});
```

## rotatestart

Срабатывает, когда начинается взаимодействие `drag to rotate`. См. раздел DragRotateHandler.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// just before a `drag to rotate` interaction starts.
map.on('rotatestart', function() {
 console.log('A rotatestart event occurred.');
});
```

## sourcedata

Срабатывает при загрузке или изменении одного из источников карты, в том числе при загрузке или изменении тайла, принадлежащей источнику.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when one of the map's sources loads or changes.
map.on('sourcedata', function() {
 console.log('A sourcedata event occurred.');
});
```

## sourcedataloading

Срабатывает, когда один из источников карты начинает загружаться или изменяться асинхронно. За всеми событиями `sourcedataloading` следует событие `sourcedata` или `error`. Дополнительные сведения см. в разделе MapDataEvent.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// map's sources begin loading or
// changing asyncronously.
map.on('sourcedataloading', function() {
 console.log('A sourcedataloading event occurred.');
});
```

## styledata

Срабатывает при загрузке или изменении стиля карты. Дополнительные сведения см. в разделе MapDataEvent.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when the map's style loads or changes.
map.on('styledata', function() {
 console.log('A styledata event occurred.');
});
```

## styledataloading

Срабатывает, когда стиль карты начинает загружаться или меняться асинхронно. За всеми событиями `styledataloading` следует событие `styledata` или `error`. Дополнительные сведения см. в разделе MapDataEvent.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// map's style begins loading or
// changing asyncronously.
map.on('styledataloading', function() {
 console.log('A styledataloading event occurred.');
});
```

## styleimagemissing

Срабатывает, когда отсутствует значок или шаблон, необходимый стилю. Отсутствующее изображение можно добавить с помощью `Map#addImage`, чтобы предотвратить пропуск изображения. Это событие можно использовать для динамической генерации иконок и шаблонов.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// an icon or pattern is missing.
map.on('styleimagemissing', function() {
 console.log('A styleimagemissing event occurred.');
});
```

## touchcancel

Срабатывает, когда на карте происходит событие `touchcancel`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when a touchcancel event occurs within the map.
map.on('touchcancel', function() {
 console.log('A touchcancel event occurred.');
});
```

## touchend

Срабатывает, когда на карте происходит событие `touchend`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when a touchstart event occurs within the map.
map.on('touchstart', function() {
 console.log('A touchstart event occurred.');
});
```

## touchmove

Срабатывает, когда на карте происходит событие `touchmove`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when a touchmove event occurs within the map.
map.on('touchmove', function() {
 console.log('A touchmove event occurred.');
});
```

## touchstart

Срабатывает, когда на карте происходит событие `touchstart`.

Параметр метода — `data:``MapTouchEvent`.

```javascript
// Initialize the map 
var map = new mmrgl.Map({ /* map options */ }); 
// Set an event listener that fires 
// when a touchstart event occurs within the map. map.on('touchstart', function() { 
 console.log('A touchstart event occurred.'); 
});
```

## webglcontextlost

Срабатывает при потере контекста `WebGL`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when the WebGL context is lost.
map.on('webglcontextlost', function() {
 console.log('A webglcontextlost event occurred.');
});
```

## webglcontextrestored

Срабатывает при восстановлении контекста `WebGL`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when the WebGL context is restored.
map.on('webglcontextrestored', function() {
 console.log('A webglcontextrestored event occurred.');
});
```

## wheel

Срабатывает, когда на карте происходит прокрутка колесом.

Параметр метода — `data:``MapWheelEvent`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// when a wheel event occurs within the map.
map.on('wheel', function() {
 console.log('A wheel event occurred.');
});
```

## zoom

Многократно срабатывает во время анимированного перехода с одного уровня масштабирования на другой в результате действий с пользователем или таких методов, как `Map#flyTo`.

Параметр метода — `data:(``MapMouseEvent` | `MapTouchEvent``)`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// repeatedly during a zoom transition.
map.on('zoom', function() {
 console.log('A zoom event occurred.');
});
```

## zoomend

Срабатывает сразу после того, как карта завершает переход с одного уровня масштабирования на другой, в результате либо действий пользователя, либо таких методов, как `Map#flyTo`.

Параметр метода — `data:(``MapMouseEvent` | `MapTouchEvent``)`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// just after a zoom transition finishes.
map.on('zoomend', function() {
 console.log('A zoomend event occurred.');
});
```

## zoomstart

Срабатывает непосредственно перед тем, как карта начинает переход от одного уровня масштабирования к другому, в результате либо действий пользователя, либо таких методов, как `Map#flyTo`.

Параметр метода — `data:(``MapMouseEvent` | `MapTouchEvent``)`.

```javascript
// Initialize the map
var map = new mmrgl.Map({ /* map options */ });
// Set an event listener that fires
// just before a zoom transition starts.
map.on('zoomstart', function() {
 console.log('A zoomstart event occurred.');
});
```
