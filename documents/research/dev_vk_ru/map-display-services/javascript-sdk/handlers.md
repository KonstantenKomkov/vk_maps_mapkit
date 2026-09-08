<!-- Источник: https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/handlers -->
<!-- Снято: 2026-09-08 -->

# Handlers (обработчики)

## BoxZoomHandler

`BoxZoomHandler` позволяет пользователю масштабировать карту так, чтобы она помещалась в ограничивающую рамку. Прямоугольник определяется нажатием и удержанием клавиши `Shift` во время перетаскивания курсора.

Путь до файла в библиотеке: `src/ui/handler/box_zoom.js`

### Методы

### disable()

Отключает `box zoom`.

#### Пример

```javascript
map.boxZoom.disable();
```

### enable()

Включает `box zoom`.

#### Пример

```javascript
map.boxZoom.enable();
```

### isActive()

Возвращает `true`, если `box zoom` активна.

### isEnabled()

Возвращает `true`, если `box zoom` включена.

## ScrollZoomHandler

`ScrollZoomHandler` позволяет пользователю масштабировать карту с помощью прокрутки.

Путь до файла в библиотеке: `src/ui/handler/scroll_zoom.js`

### Методы

### disable()

Выключает `scroll to zoom`.

#### Пример

```javascript
map.scrollZoom.disable();
```

### enable(options?)

Параметр метода — `around`. Если `center` пройден, карта будет масштабироваться вокруг центра карты.

#### Пример

```javascript
// without around
map.scrollZoom.enable();

// with around
map.scrollZoom.enable({ around: 'center' });
```

### isEnabled()

Возвращает `true`, если `scroll to zoom` включена.

### setWheelZoomRate(wheelZoomRate)

Установите скорость масштабирования колесика мыши.

Параметр метода — `wheelZoomRate`. Скорость масштабирования. По умолчанию — `1/450`.

#### Пример

```javascript
// Slow down zoom of mouse wheel
map.scrollZoom.setWheelZoomRate(1/600);
```

### setZoomRate(zoomRate)

Установите скорость масштабирования трекпада.

Параметр метода — `zoomRate`. Скорость масштабирования. По умолчанию — `1/100`.

#### Пример

```javascript
// Speed up trackpad zoom
map.scrollZoom.setZoomRate(1/25);
```

## DragPanHandler

DragPanHandler позволяет пользователю перемещать карту, щелкая и перетаскивая курсор.

Путь до файла в библиотеке: `src/ui/handler/shim/drag_pan.js`

### Методы

### disable()

Отключает `drag to pan`.

#### Пример

```javascript
map.dragPan.disable();
```

### enable(options?)

Включает `drag to pan`.

Параметры:

- `linearity` — коэффициент, используемый для масштабирования скорости сопротивления (`drag velocity`);
- `easing` — функция сглаживания (`easing function`) применяется к `map.panTo` при перетаскивании;
- `maxSpeed` — максимальное значение скорости лобового сопротивления;
- `deceleration` — скорость, с которой уменьшается движение после касания.

#### Пример

```javascript
// without options
map.dragPan.enable(); 

// with options
map.dragPan.enable({
 linearity: 0.3,
 easing: bezier(0, 0, 0.3, 1),
 maxSpeed: 1400,
 deceleration: 2500,
});
```

### isActive()

Возвращает `true`, если `drag to pan` активна.

### isEnabled()

Возвращает `true`, если `drag to pan` включена.

## DragRotateHandler

`DragRotateHandler` позволяет пользователю вращать карту, щелкая и перетаскивая курсор, удерживая правую кнопку мыши или клавишу `ctrl`.

Путь до файла в библиотеке: `src/ui/handler/shim/drag_rotate.js`

### Методы

### disable()

Отключает `drag to rotate`.

#### Пример

```javascript
map.dragRotate.disable();
```

### enable()

Включает `drag to rotate`.

### Пример

```javascript
map.dragRotate.enable();
```

### isActive()

Возвращает `true`, если `drag to rotate` активна.

### isEnabled()

Возвращает `true`, если `drag to rotate` включена.

## KeyboardHandler

`KeyboardHandler` позволяет пользователю масштабировать, поворачивать и панорамировать карту с помощью следующих сочетаний клавиш:

- `=` / `+` — увеличивает уровень масштабирования на `1`;
- `Shift` + `=` / `Shift` + `+` — увеличивает уровень масштабирования на `2`;
- `-` — уменьшает уровень масштабирования на `1`;
- `Shift` + `-` — уменьшает уровень масштабирования на `2`;
- Клавиши со стрелками (`Arrow keys`) — перемещает вьюпорт на `100` пикселей;
- `Shift` + `⇢` — поворачивает карту на 15 градусов по часовой стрелке;
- `Shift` + `⇠` — поворачивает карту на 15 градусов против часовой стрелки;
- `Shift` + `⇡` — увеличивает наклон на 10 градусов;
- `Shift` + `⇣` — уменьшает наклон на 10 градусов.

Путь до файла в библиотеке: `src/ui/handler/keyboard.js`

### Методы

### disable()

Отключает `keyboard rotate and zoom`.

#### Пример

```javascript
map.keyboard.disable();
```

### disableRotation()

Отключает `keyboard pan/rotate`, но оставляет включенным `keyboard zoom`.

#### Пример

```javascript
map.keyboard.disableRotation();
```

### enable()

Включает `keyboard rotate and zoom`.

#### Пример

```javascript
map.keyboard.enable();
```

### enableRotation()

Включает `keyboard pan/rotate`.

#### Пример

```javascript
map.keyboard.enableRotation();
```

### isActive()

Возвращает `true`, если обработчик включен и обнаружил начало `zoom` или `rotate`.

### isEnabled()

Возвращает `true`, если включено взаимодействие `keyboard rotate and zoom`.

## DoubleClickZoomHandler

`DoubleClickZoomHandler` позволяет пользователю масштабировать карту в определенной точке двойным щелчком или двойным тапом.

Путь до файла в библиотеке: `src/ui/handler/shim/dblclick_zoom.js`

### Методы

### disable()

Отключает `double click to zoom`.

#### Пример

```javascript
map.doubleClickZoom.disable();
```

### enable()

Включает `double click to zoom`.

#### Пример

```javascript
map.doubleClickZoom.enable();
```

### isActive()

Возвращает `true`, если `double click to zoom` активна.

### isEnabled()

Возвращает `true`, если `double click to zoom` включена.

## TouchZoomRotateHandler

`TouchZoomRotateHandler` позволяет пользователю увеличивать и поворачивать карту, нажимая на сенсорный экран.

Пользователь может увеличивать масштаб одним пальцем, дважды нажимая и перетаскивая. При втором касании необходимо удерживать палец и перетаскивать его вверх или вниз, чтобы увеличить или уменьшить масштаб.

Путь до файла в библиотеке: `src/ui/handler/shim/touch_zoom_rotate.js`

### Методы

### disable()

Отключает `pinch to rotate and zoom`.

#### Пример

```javascript
map.touchZoomRotate.disable();
```

### disableRotation()

Отключает `pinch to rotate`, оставляя `pinch to zoom`.

#### Пример

```javascript
map.touchZoomRotate.disableRotation();
```

### enable(options?)

Включает `pinch to rotate and zoom`.

Параметр метода — `around`. Если `center` пройден, карта будет масштабироваться вокруг центра карты.

#### Пример

```javascript
// without around
map.touchZoomRotate.enable();

// with around
map.touchZoomRotate.enable({ around: 'center' });
```

### enableRotation()

Включает `pinch to rotate`.

#### Пример

```javascript
map.touchZoomRotate.enable();
map.touchZoomRotate.enableRotation();
```

### isActive()

Возвращает `true`, если обработчик включен и обнаружил `zoom` или `rotate`.

### isEnabled()

Возвращает `true`, если `pinch to rotate and zoom` включена.

## TouchPitchHandler

TouchPitchHandler позволяет пользователю наклонять карту, перетаскивая ее вверх и вниз двумя пальцами.

Путь до файла в библиотеке: `src/ui/handler/touch_zoom_rotate.js`

### Методы

### disable()

Отключает `drag to pitch`.

#### Пример

```javascript
map.touchPitch.disable();
```

### enable()

Включает `drag to pitch`.

#### Пример

```javascript
map.touchPitch.enable();
```

### isActive()

Возвращает `true`, если `drag to pitch` активна.

### isEnabled()

Возвращает `true`, если `drag to pitch` включена.
