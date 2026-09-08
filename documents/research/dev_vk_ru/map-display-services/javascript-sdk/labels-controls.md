<!-- Источник: https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/labels-controls -->
<!-- Снято: 2026-09-08 -->

# Метки и элементы управления

## Marker

Создание маркера

Путь до файла в библиотеке: `src/ui/marker.js`

### Параметры

| Название | Тип | Описание |
| --- | --- | --- |
| `element` | `HTMLElement` | Позволяет использовать DOM элемент в качестве маркера. По умолчанию используется голубой, каплевидный svg маркер (`light blue`, `droplet-shaped`). |
| `anchor` | `string` `default: 'center'` | Определяет позицию иконки относительно ее центра. Доступные значения: `center`, `top`, `bottom`, `left`, `right`, `top-left`, `top-right`, `bottom-left` и `bottom-right`. |
| `offset` | `PointLike` | Смещение, применяемое относительно центра элемента. Отрицательные значения указывают влево и вверх. |
| `color` | `string` `default: '#3FB1CE'` | Если `options.element` не указан, то будет использоваться этот цвет. По умолчанию используется светло-синий цвет. |
| `scale` | `number` `default: 1` | Если `options.element` не указан, то будет использоваться этот масштаб. По умолчанию шкала соответствует высоте `41px` и ширине `27px`. |
| `draggable` | `boolean` `default: false` | Если `true`, то можно перетаскивать маркеры на новое место (`drag and drop`) |
| `clickTolerance` | `number` `default: 0` | Максимальное количество пикселей, на которое пользователь может переместить указатель мыши во время щелчка по маркеру, чтобы он считался допустимым щелчком (в отличие от перетаскивания маркера). По умолчанию используется наследование `clickTolerance` карты. |
| `rotation` | `number` `default: 0` | Угол поворота маркера относительно его соответствующей `rotationAlignment` . Положительное значение будет вращать маркер по часовой стрелке. |
| `pitchAlignment` | `string` `default: 'auto'` | • `map` — выравнивает маркер по плоскости карты (`map`);
• `viewport` — выравнивает маркер по плоскости экрана (`viewport`);
• `auto` — автоматически соответствует значению `rotationAlignment`. |
| `rotationAlignment` | `string` `default: 'auto'` | • `map` — выравнивает поворот маркера относительно карты (`map`), сохраняя пеленг при вращении карты;
• `viewport` — выравнивает поворот маркера относительно экрана (`viewport`), не зависящего от поворотов карты;
• `auto` — эквивалентно экрану (`viewport`). |

#### Пример

```javascript
var marker = new mmrgl.Marker()
  .setLngLat([30.5, 50.5])
  .addTo(map);

// Set options
var marker = new mmrgl.Marker({
 color: "#FFFFFF",
 draggable: true
}).setLngLat([30.5, 50.5])
  .addTo(map);
```

### Методы

### addTo(map)

Прикрепляет маркер к объекту карты.

#### Пример

```javascript
var marker = new mmrgl.Marker() 
 .setLngLat([30.5, 50.5]) 
 .addTo(map); // add the marker to the map
```

### getElement()

Возвращает HTML-элемент маркера.

### getLngLat()

Позволяет получить географическое местоположение маркера. Долгота результата может отличаться кратно 360 градусам от долготы, ранее установленной `setLngLat`, потому что маркер обертывает якорную долготу по копиям мира, чтобы сохранить маркер на экране.

### getOffset()

Возвращает смещение маркера.

### getPitchAlignment()

Возвращает текущее значение свойства `pitchAlignment` маркера.

### getPopup()

Возвращает экземпляр всплывающего окна, привязанный к маркеру.

#### Пример

```javascript
var marker = new mmrgl.Marker()
.setLngLat([0, 0])
.setPopup(new mmrgl.Popup().setHTML("<h1>Hello World!</h1>"))
.addTo(map);`<br/><br/>`console.log(marker.getPopup()); // return the popup instance
```

### getRotation()

Возвращает текущий угол поворота маркера (в градусах).

### getRotationAlignment()

Возвращает текущее свойство `rotationAlignment` маркера.

### isDraggable()

Возвращает `true`, если маркер можно перетащить.

### remove()

Удаляет маркер с карты.

#### Пример

```javascript
var marker = new mmrgl.Marker().addTo(map);
marker.remove();
```

### setDraggable(shouldBeDraggable)

Задает перетаскиваемое свойство и функциональность маркера.

Параметр метода — `shouldBeDraggable:boolean`. Включает или выключает функцию перетаскивания. По умолчанию `false`.

### setLngLat(lnglat)

Устанавливает географическое положение маркера и перемещает его.

Параметр метода — `lnglat:LngLat`. Где должен быть расположен маркер.

#### Пример

```javascript
// Create a new marker, set the longitude and latitude, and add it to the map
new mmrgl.Marker()
.setLngLat([-65.017, -16.457])
.addTo(map);
```

### setOffset(offset)

Устанавливает смещение маркера.

Параметр метода — `offset:PointLike`. Смещение в пикселях, применяемое относительно центра элемента. Отрицательные значения указывают влево и вверх.

### setPitchAlignment(alignment?)

Задает свойство `pitchAlignment` маркера.

Параметр метода — `alignment:string`. Задает свойство `pitchAlignment` маркера. Если `auto`, оно автоматически будет соответствовать поворотному `rotationAlignment`.

### setPopup(popup)

Привязывает всплывающее окно к маркеру.

Параметр метода — `popup:Popup`. Экземпляр всплывающего класса. Если значение `undefined` или `null`, то любое всплывающее окно, установленное в этом экземпляре маркера, будет снято.

#### Пример

```javascript
var marker = new mmrgl.Marker()
 .setLngLat([0, 0])
 .setPopup(new mmrgl.Popup().setHTML("<h1>Hello World!</h1>")) // add popup
 .addTo(map);
```

### setRotation(rotation)

Задает свойство поворота маркера.

Параметр метода — `rotation:number`. Угол поворота маркера (по часовой стрелке, в градусах) относительно соответствующего `Marker#setRotationAlignment setting`. По умолчанию `0`.

### setRotationAlignment(alignment)

Задает свойство `rotationAlignment` маркера.

Параметр метода — `alignment:string`. Устанавливает свойство `rotationAlignment` маркера. По умолчанию — `auto`.

### togglePopup()

Открывает или закрывает экземпляр всплывающего окна, привязанный к маркеру, в зависимости от текущего состояния всплывающего окна.

#### Пример

```javascript
var marker = new mmrgl.Marker()
 .setLngLat([0, 0])
 .setPopup(new mmrgl.Popup().setHTML("<h1>Hello World!</h1>"))
 .addTo(map);`<br/><br/>`marker.togglePopup(); // toggle popup open or closed
```

### События

| Название | Описание |
| --- | --- |
| `drag` | Срабатывает во время перетаскивания. |
| `dragend` | Срабатывает, когда перетаскивание заканчивается. |
| `dragstart` | Срабатывает при начале перетаскивания. |

## Popup

Создание всплывающего блока.

Путь до файла в библиотеке: `src/ui/popup.js`

### Параметры

| Название | Тип | Описание |
| --- | --- | --- |
| `maxWidth` | `string` `default: '240px'` | Строка, которая задает CSS-свойство максимальной ширины всплывающего окна, например `300px`. Чтобы убедиться, что размер всплывающего окна соответствует его содержимому, установите для этого свойства значение `none`. Доступные значения можно найти здесь: [https://developer.mozilla.org/en-US/docs/Web/CSS/max-width](https://vk.ru/away.php?to=https%3A%2F%2Fdeveloper.mozilla.org%2Fen-US%2Fdocs%2FWeb%2FCSS%2Fmax-width). |
| `anchor` | `string` `default: 'bottom'` | Определяет позицию иконки относительно ее центра. Доступные значения: `center`, `top`, `bottom`, `left`, `right`, `top-left`, `top-right`, `bottom-left` и `bottom-right`. |
| `offset` | `number` | `PointLike` |
| `className` | `string` | Имя класса для контейнера. |
| `focusAfterOpen` | `boolean` `default: true` | Если `true`, то после открытия окна, будет произведена попытка установить фокус (курсор) в первый элемент внутри окна, который это поддерживает, например `<input/>`. |
| `closeOnMove` | `boolean` `default: false` | Если `true`, то всплывающее окно будет закрыто при перемещении карты. |
| `closeOnClick` | `boolean` `default: true` | Если `true`, то всплывающее окно будет закрыто при нажатии на карту. |
| `closeButton` | `boolean` `default: true` | Если `true`, то в правом верхнем углу всплывающего окна появится кнопка закрытия. |

#### Пример

```javascript
var markerHeight = 50, markerRadius = 10, linearOffset = 25;
var popupOffsets = {
 'top': [0, 0],
 'top-left': [0,0],
 'top-right': [0,0],
 'bottom': [0, -markerHeight],
 'bottom-left': [linearOffset, (markerHeight - markerRadius + linearOffset) * -1],
 'bottom-right': [-linearOffset, (markerHeight - markerRadius + linearOffset) * -1],
 'left': [markerRadius, (markerHeight - markerRadius) * -1],
 'right': [-markerRadius, (markerHeight - markerRadius) * -1]
};
var popup = new mmr
gl.Popup({offset: popupOffsets, className: 'my-class'})
  .setLngLat(e.lngLat)
  .setHTML("<h1>Hello World!</h1>")
  .setMaxWidth("300px")
  .addTo(map);
```

### Методы

### addClassName(className)

Добавляет CSS класс к элементу всплывающего контейнера.

Параметр метода — `className:string`. Непустая строка с именем класса для добавления к всплывающему контейнеру.

#### Пример

```javascript
let popup = new mmrgl.Popup()
popup.addClassName('some-class')
```

### addTo(map)

Добавляет всплывающее окно на карту.

### Пример

```javascript
new mmrgl.Popup()
.setLngLat([0, 0])
.setHTML("<h1>Null Island</h1>")
.addTo(map);
```

### getElement()

Возвращает HTML-элемент всплывающего окна.

#### Пример

```javascript
// Change the 'Popup' element's font size`<br/>`var popup = new mmrgl.Popup()`<br/>` .setLngLat([-96, 37.8])`<br/>` .setHTML("<p>Hello World!</p>")`<br/>` .addTo(map);
var popupElem = popup.getElement();
popupElem.style.fontSize = "25px";
```

### getLngLat()

Возвращает географическое местоположение якоря всплывающего окна. Долгота результата может отличаться кратно 360 градусам от долготы, ранее установленной `setLngLat`, потому что попап обертывает якорную долготу по копиям мира, чтобы сохранить всплывающее окно на экране.

### getMaxWidth()

Возвращает максимальную ширину всплывающего окна.

### isOpen()

Возвращает `true`, если всплывающее окно открыто, `false`, если оно закрыто.

### remove()

Удаляет всплывающее окно с карты, на которую оно было добавлено.

#### Пример

```javascript
var popup = new mmrgl.Popup().addTo(map);
popup.remove();
```

### removeClassName(className)

Удаляет CSS класс из всплывающего элемента контейнера.

Параметр метода — `className:string`. Непустая строка с именем класса CSS для удаления из всплывающего контейнера.

#### Пример

```javascript
let popup = new mmrgl.Popup()
popup.removeClassName('some-class')
```

### setDOMContent(htmlNode)

Устанавливает содержимое всплывающего окна на элемент, предоставленный в качестве узла DOM.

Параметр метода — `htmlNode:Node`. Узел DOM, который будет использоваться в качестве содержимого для всплывающего окна.

#### Пример

```javascript
// create an element with the popup content`<br/>`var div = window.document.createElement('div');`<br/>`div.innerHTML = 'Hello, world!';`<br/>`var popup = new mmrgl.Popup()
 .setLngLat(e.lngLat)
 .setDOMContent(div)
 .addTo(map);
```

### setHTML(html)

Устанавливает содержимое всплывающего окна в HTML-код, предоставленный в виде строки. Этот метод не выполняет фильтрацию HTML или дезинфекцию и должен использоваться только с доверенным контентом. Рассмотрим `Popup#setText`, если содержимое является ненадежной текстовой строкой.

Параметр метода — `html:string`. Строка, представляющая HTML-содержимое всплывающего окна.

#### Пример

```javascript
var popup = new mmrgl.Popup()
 .setLngLat(e.lngLat)
 .setHTML("<h1>Hello World!</h1>")
 .addTo(map);
```

### setLngLat(lnglat)

Устанавливает географическое местоположение якоря всплывающего окна и перемещает его к нему. Заменяет поведение `trackPointer()`.

Параметр метода — `lnglat:LngLatLike`. Географическое положение, которое нужно установить в качестве якоря всплывающего окна.

### setMaxWidth(maxWidth)

Устанавливает максимальную ширину всплывающего окна. Это установка свойства CSS `max-width`. Доступные значения можно найти в [MDN](https://vk.ru/away.php?to=https%3A%2F%2Fdeveloper.mozilla.org%2Fen-US%2Fdocs%2FWeb%2FCSS%2Fmax-width).

Параметр метода — `maxWidth:string`. Строка, представляющая значение максимальной ширины.

### setOffset(offset?)

Устанавливает смещение всплывающего окна.

Параметр метода — `offset:Offset`. Смещение попапа.

### setText(text)

Устанавливает содержимое всплывающего окна в виде строки текста. Эта функция создает текстовый узел в DOM, поэтому она не может вставлять необработанный HTML. Используйте этот метод для защиты от XSS, если всплывающее содержимое предоставлено пользователем.

Параметр метода — `text:string`. Текстовое содержимое для всплывающего окна.

#### Пример

```javascript
var popup = new mmrgl.Popup()
 .setLngLat(e.lngLat)
 .setText('Hello, world!')
 .addTo(map);
```

### toggleClassName(className)

Добавьте или удалите данный класс CSS во всплывающем контейнере, в зависимости от того, есть ли в контейнере в данный момент этот класс.

Параметр метода — `className:string`. Непустая строка с именем класса CSS для добавления или удаления.

#### Пример

```javascript
let popup = new mmrgl.Popup()
popup.toggleClassName('toggleClass')
```

### trackPointer()

Отслеживает всплывающий якорь до положения курсора на экранах с помощью указателя (он будет скрыт на сенсорных экранах). Заменяет поведение `setLngLat`. Для большинства случаев использования установите `closeOnClick` и `closeButton` в `false`.

#### Пример

```javascript
var popup = new mmrgl.Popup({ closeOnClick: false, closeButton: false })
 .setHTML("<h1>Hello World!</h1>")
 .trackPointer()
 .addTo(map);
```

### События

**close** — cрабатывает, когда всплывающее окно закрывается вручную или программно.

```javascript
// Create a popup
var popup = new mmrgl.Popup();
// Set an event listener that will fire
// any time the popup is closed
popup.on('close', function(){
 console.log('popup was closed');
});
```

**open** — срабатывает, когда всплывающее окно открывается вручную или программно.

```javascript
// Create a popup
var popup = new mmrgl.Popup();
// Set an event listener that will fire
// any time the popup is opened
popup.on('open', function(){
 console.log('popup was opened');
});
```

## IControl (Спецификация)

Интерфейс для элементов интерактивного управления, добавленных на карту. Это спецификация для разработчиков: это не метод или класс.

Элементы управления должны реализовывать `onAdd` и `onRemove` так же это должен быть `<div>`. Чтобы использовать стиль элемента управления `MMR GL JS`, добавьте класс `mmrgl-ctrl`.

Путь до файла в библиотеке: `src/ui/map.js`

#### Пример

```javascript
// Control implemented as ES6 class
class HelloWorldControl {
 onAdd(map) {
 this._map = map;
 this._container = document.createElement('div');
 this._container.className = 'mmrgl-ctrl';
 this._container.textContent = 'Hello, world';
 return this._container;
    }

 onRemove() {
 this._container.parentNode.removeChild(this._container);
 this._map = undefined;
    }
}

// Control implemented as ES5 prototypical class
function HelloWorldControl() { }

HelloWorldControl.prototype.onAdd = function(map) {
 this._map = map;
 this._container = document.createElement('div');
 this._container.className = 'mmrgl-ctrl';
 this._container.textContent = 'Hello, world';
 return this._container;
};

HelloWorldControl.prototype.onRemove = function () {
 this._container.parentNode.removeChild(this._container);
 this._map = undefined;
};
```

### Методы

| Название | Описание |
| --- | --- |
| `getDefaultPosition()` | При необходимости укажите положение по умолчанию для этого элемента управления. Если этот метод реализован и `Map#addControl` вызывается без параметра `position`, то в качестве позиции элемента управления будет использоваться значение, возвращаемое `getDefaultPosition`. |
| `onAdd(map)` | Позволяет регистрировать элемент управления на карте и даёт ему возможность зарегистрировать лисенер событий и ресурсы. Этот метод вызывается `Map#addControl` внутренне. |
| `onRemove(map)` | Отменяет регистрацию элемента управления на карте и даёт ему возможность отсоединить лисенер событий и ресурсы. Этот метод вызывается `Map#removeControl` внутренне. |

## NavigationControl

Элемент управления `NavigationControl` содержит кнопки масштабирования (`zoom`) и компас (`compass`).

Путь до файла в библиотеке: `src/ui/control/navigation_control.js`

### Параметры

| Название | Тип | Описание |
| --- | --- | --- |
| `showCompass` | `boolean` `default: true` | Если `true`, то кнопка компаса отображается. |
| `showZoom` | `boolean` `default: true` | Если `true`, то кнопки увеличения и уменьшения масштаба отображаются. |
| `visualizePitch` | `boolean` `default: false` | Если `true`, то шаг визуализируется вращением оси `X`. |

#### Пример

```javascript
var nav = new mmrgl.NavigationControl();
map.addControl(nav, 'top-left');
```

## GeolocateControl

Элемент управления `GeolocateControl` предоставляет кнопку, которая использует API геолокации браузера для определения местоположения пользователя на карте.

Не все браузеры поддерживают геолокацию, и некоторые пользователи могут отключить эту функцию. Поддержка геолокации для современных браузеров, включая Chrome, требует, чтобы сайты обслуживались по протоколу HTTPS. Если поддержка геолокации недоступна, то `GeolocateControl` будет отображаться как отключенный.

Уровень масштабирования будет зависеть от точности геолокации, обеспечиваемой устройством.

`GeolocateControl` имеет два режима. Если `trackUserLocation` имеет значение `false` (по умолчанию), то элемент управления действует как кнопка, которая при нажатии настраивает камеру карты на местоположение пользователя. Если пользователь перемещается, карта не обновляется. Это больше всего подходит для рабочего стола. Если `trackUserLocation` имеет значение `true`, то элемент управления действует как кнопка переключения, которая отслеживает передвижение пользователя. В этом режиме `GeolocateControl` имеет три состояния взаимодействия:

- `active` — камера карты автоматически обновляется по мере изменения местоположения пользователя, сохраняя точку местоположения в центре;
- `passive` — точка местоположения пользователя автоматически обновляется, но камера карты — нет. Происходит при инициировании пользователем перемещения карты;
- `disabled` — происходит, если геолокация недоступна, отключена или запрещена.

Этими состояниями взаимодействия нельзя управлять программно, они задаются на основе взаимодействия с пользователем.

Путь до файла в библиотеке: `src/ui/control/geolocate_control.js`

### Параметры

| Название | Тип | Описание |
| --- | --- | --- |
| `positionOptions` | `Object` `default: { enableHighAccuracy:false, timeout:6000}` | Объект `PositionOptions` API геолокации. |
| `fitBoundsOptions` | `Object` `default: { maxZoom:15}` | `Map#fitBounds` объект `Options`, который используется, когда карта перемещается и масштабируется до местоположения пользователя. По умолчанию используется `maxZoom: 15`, чтобы ограничить масштаб карты для очень точных местоположений. |
| `trackUserLocation` | `boolean` `default: false` | Если `true`, то элемент управления `Geolocate` становится переключателем и, когда он активен, карта будет получать обновления о местоположении пользователя по мере его изменений. |
| `showAccuracyCircle` | `boolean` `default: true` | Если `showUserLocation` имеет значение `true`, вокруг местоположения пользователя будет нарисован прозрачный круг, указывающий точность местоположения пользователя (точность 95%). Установите значение `false` для отключения. Всегда отключается, когда `showUserLocation` имеет значение `false`. |
| `showUserLocation` | `boolean` `default: true` | По умолчанию точка будет отображаться на карте в месте расположения пользователя. Установите значение `false` для отключения. |

#### Пример

```javascript
map.addControl(new mmrgl.GeolocateControl({
 positionOptions: {
 enableHighAccuracy: true
  },
 trackUserLocation: true
}));
```

### Методы

### trigger

Метод позволяет программно запросить и переместить карту в местоположение пользователя.

#### Пример

```javascript
// Initialize the geolocate control.
var geolocate = new mmrgl.GeolocateControl({
 positionOptions: {
 enableHighAccuracy: true
  },
 trackUserLocation: true
});
// Add the control to the map.
map.addControl(geolocate);
map.on('load', function() {
  geolocate.trigger();
});
```

### События

### error

Срабатывает при каждом неуспешном обновлении позиции в Geolocation API.

Параметр метода — `data:PositionError`. Возвращаемый объект `PositionError` из обратного вызова в `Geolocation.getCurrentPosition()` или `Geolocation.watchPosition()`.

#### Пример

```javascript
// Initialize the geolocate control.
var geolocate = new mmrgl.GeolocateControl({
 positionOptions: {
 enableHighAccuracy: true
  },
 trackUserLocation: true
});
// Add the control to the map.
map.addControl(geolocate);
// Set an event listener that fires
// when an error event occurs.
geolocate.on('error', function() {
 console.log('An error event has occurred.')
});
```

### geolocate

Срабатывает при каждом успешном обновлении позиции в Geolocation API.

Параметр метода — `data:Position`. Возвращаемый объект `Position` из вызова в `Geolocation.getCurrentPosition()` или `Geolocation.watchPosition()`.

#### Пример

```javascript
// Initialize the geolocate control.
var geolocate = new mmrgl.GeolocateControl({
 positionOptions: {
 enableHighAccuracy: true
  },
 trackUserLocation: true
});
// Add the control to the map.
map.addControl(geolocate);
// Set an event listener that fires
// when a geolocate event occurs.
geolocate.on('geolocate', function() {
 console.log('A geolocate event has occurred.')
});
```

### outofmaxbounds

Срабатывает при каждом успешном обновлении позиции в Geolocation API, при этом позиция пользователя находится вне `maxBounds`.

Параметр метода — `data:Position`. Возвращаемый объект `Position` из вызова в `Geolocation.getCurrentPosition()` или `Geolocation.watchPosition()`.

#### Пример

```javascript
// Initialize the geolocate control.
var geolocate = new mmrgl.GeolocateControl({
 positionOptions: {
 enableHighAccuracy: true
  },
 trackUserLocation: true
});
// Add the control to the map.
map.addControl(geolocate);
// Set an event listener that fires
// when an outofmaxbounds event occurs.
geolocate.on('outofmaxbounds', function() {
 console.log('An outofmaxbounds event has occurred.')
});
```

### trackuserlocationend

Срабатывает, когда элемент управления `Geolocate` переходит в фоновое состояние. Это происходит, когда пользователь меняет камеру во время активной позиции. Это применимо только в том случае, если `trackUserLocation` имеет значение `true`. В фоновом режиме точка на карте будет обновляться с обновлением местоположения, но камера — нет.

#### Пример

```javascript
// Initialize the geolocate control.
var geolocate = new mmrgl.GeolocateControl({
 positionOptions: {
 enableHighAccuracy: true
  },
 trackUserLocation: true
});
// Add the control to the map.
map.addControl(geolocate);
// Set an event listener that fires
// when a trackuserlocationend event occurs.
geolocate.on('trackuserlocationend', function() {
 console.log('A trackuserlocationend event has occurred.')
});
```

### trackuserlocationstart

Срабатывает, когда элемент управления `Geolocate` переходит в активное состояние, это происходит либо при первом получении успешной позиции API геолокации для пользователя (за этим последует событие `geolocate`), либо пользователь нажимает кнопку `geolocate`, находясь в фоновом состоянии, которое использует последнюю известную позицию для повторного центрирования карты и входа в активное состояние (событие `geolocate` не последует, если местоположение пользователя не изменится).

#### Пример

```javascript
// Initialize the geolocate control.
var geolocate = new mmrgl.GeolocateControl({
 positionOptions: {
 enableHighAccuracy: true
  },
 trackUserLocation: true
});
// Add the control to the map.
map.addControl(geolocate);
// Set an event listener that fires
// when a trackuserlocationstart event occurs.
geolocate.on('trackuserlocationstart', function() {
 console.log('A trackuserlocationstart event has occurred.')
});
```

## ScaleControl

Элемент управления `ScaleControl` отображает отношение расстояния на карте к соответствующему расстоянию на земле.

Путь до файла в библиотеке: `src/ui/control/scale_control.js`

### Параметры

| Название | Тип | Описание |
| --- | --- | --- |
| `maxWidth` | `number` `default: '100'` | Максимальная длина элемента управления масштабом в пикселях. |
| `unit` | `string` `default: 'metric'` | Единица измерения расстояния: `imperial`, `metric` или `nautical`. |

#### Пример

```javascript
var scale = new mmrgl.ScaleControl({
 maxWidth: 80,
 unit: 'imperial'
});
map.addControl(scale);
scale.setUnit('metric');
```

### Методы

### setUnit(unit)

Установите единицу измерения расстояния на шкале.

Параметр метода — `unit:Unit`. Единица измерения расстояния: `imperial`, `metric` или `nautical`.

## FullscreenControl

Элемент управления `FullscreenControl` содержит кнопку для переключения карты в полноэкранный режим и обратно.

Путь до файла в библиотеке: `src/ui/control/fullscreen_control.js`

### Параметры

| Название | Тип | Описание |
| --- | --- | --- |
| `container` | `HTMLElement` | Элемент DOM, который открывается в полноэкранном режиме. По умолчанию контейнер карты будет использоваться для полноэкранного режиме. |

#### Пример

```javascript
map.addControl(new mmrgl.FullscreenControl({container:
 document.querySelector('body')
}));
```
