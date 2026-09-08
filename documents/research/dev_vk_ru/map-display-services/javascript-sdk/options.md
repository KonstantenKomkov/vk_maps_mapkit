<!-- Источник: https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/options -->
<!-- Снято: 2026-09-08 -->

# Свойства и опции

## accessToken

Токен доступа к карте.

Путь до файла в библиотеке: `src/index.js`

#### Пример

```javascript
mmrgl.accessToken = myAccessToken;
```

## baseApiUrl

Начальный API URL, используемый для получения тайлов, стилей, спрайтов и глифов.

Путь до файла в библиотеке: `src/index.js`

#### Пример

```javascript
mmrgl.baseApiUrl = 'https://maps.vk.com/api';
```

## workerCount

Количество веб-воркеров на странице с `MMR GL JS` картами. По умолчанию это половина числа ядер (ограничено `6`). Обязательно нужно устанавливать этот параметр перед инициализацией карты.

Путь до файла в библиотеке: `src/index.js`

#### Пример

```javascript
mmrgl.workerCount = 2;
```

## maxParallelImageRequests

Максимальное количество изображений (растровых тайлов, спрайтов, иконок) для параллельной загрузки. Влияет на производительность в растровых картах. По умолчанию — `16`.

Путь до файла в библиотеке: `src/index.js`

#### Пример

```javascript
mmrgl.maxParallelImageRequests = 10;
```

## supported

Проверяет поддержку браузером `MMR GL JS`.

Путь до файла в библиотеке: `src/index.js`

#### Пример

```javascript
if (!mmrgl.supported()) {
 alert('Your browser does not support MMR GL JS');
}
```

## version

Версия текущей сборки `MMR GL JS`.

Путь до файла в библиотеке: `src/index.js`

#### Пример

```javascript
console.log(mmrgl.version);
//> 1.2.3;
```

## setRTLTextPlugin

Устанавливает плагин для поддержки RTL. Необходимо для поддержки арабского и еврейского языков.

Путь до файла в библиотеке: `src/index.js`

Параметры:

- `pluginURL:string` — путь до RTL плагина;
- `callback:function(error:object)` — функция вызывается, если есть ошибка;
- `lazy:boolean` — ленивая подгрузка.

#### Пример

```javascript
mmrgl.setRTLTextPlugin(pluginUrl, function(error) {
 if (error) {
 console.log('something was wrong', error);
    } else {
 console.log('rtl-text-plugin loaded successfully');
    }
}, true);
```

## getRTLTextPluginStatus

Получаем статус RTL плагина. Статус плагина может быть:

- `unavailable` — не запрошено или удалено;
- `loading` — загружается;
- `loaded` — загружен;
- `error` — ошибка загрузки.

Если статус `loaded` и плагин запрашивается снова, то будет выдана ошибка.

Путь до файла в библиотеке: `src/index.js`

#### Пример

```javascript
const pluginStatus = mmrgl.getRTLTextPluginStatus();
```

## clearStorage

Очищает `cacheStorage`, в котором могут храниться кеш тайлов

Путь до файла в библиотеке: `src/index.js`

Параметр метода — `callback:function(error:object)`. Путь до RTL плагина.

#### Пример

```javascript
mmrgl.clearStorage()
```

## AnimationOptions (группа параметров)

Параметры, влияющие на анимацию (используются в методах: `Map#panBy`, `Map#easeTo`), контролируют продолжительность и функцию плавности анимации (`easing function`). Являются необязательными.

Путь до файла в библиотеке: `src/ui/camera.js`

Параметры:

- `duration:number` — продолжительность анимации (в миллисекундах);
- `easing:function` — функция, принимающая время в диапазоне `0..1` и возвращающая число, где `0` — начальное состояние, а `1` — конечное;
- `offset:PointLike` — смещение центра относительно реального центра контейнера карты в конце анимации;
- `animate:boolean` — если `false`, анимации будут отключены;
- `essential:boolean` — если `true`, то анимация считается существенной и не будет затронута `prefers-reduced-motion` (предпочитает уменьшенное движение).

## CameraOptions (группа параметров)

Параметры, влияющие на камеру (используются в методах: `Map#jumpTo`, `Map#easeTo` и `Map#flyTo`), контролируют `location` (стартовая позиция), `zoom` (масштабирование), `bearing` и `pitch` камеры. Все свойства являются необязательными.

Путь до файла в библиотеке: `src/ui/camera.js`

Параметры:

- `center:LngLatLike` — центр карты;
- `zoom:number` — удаленность (масштаб) карты;
- `bearing:number` — нужный пеленг в градусах. Пеленг — это направление компаса, которое находится «вверх». Например, пеленг: 90 ориентирует карту так, чтобы восток был вверх.
- `pitch:number` — желаемый наклон карты в градусах. Тангаж — угол к горизонту, измеряемый в градусах с диапазоном от 0 до 60 градусов. Например, `pitch: 0` обеспечивает видимость взгляда прямо вниз на карту, в то время как `pitch: 60` наклоняет перспективу пользователя к горизонту. Увеличение значения наклона часто используется для отображения 3D-объектов;
- `around:LngLatLike` — если задан `zoom`, `around` определяет точку, вокруг которой центрируется `zoom`;
- `padding:PaddingOptions` — применяется к каждой стороне `viewport`'а для смещения точки схода (актуально когда карта наклонена).

## PaddingOptions (группа параметров)

Параметры отступов (используются в методах: `Map#fitBounds`, `Map#fitScreenCoordinates` и `Map#setPadding`). Отрегулируйте эти параметры, чтобы установить количество отступов в пикселях, добавленных к краям карты. Все свойства этого объекта должны быть неотрицательными целыми числами.

Путь до файла в библиотеке: `src/ui/camera.js`

Параметры:

- `top:number` — отступ в пикселях сверху карты;
- `bottom:number` — отступ в пикселях снизу карты;
- `left:number` — отступ в пикселях слева карты;
- `right:number` — отступ в пикселях справа карты.

#### Пример задания отдельных значений для каждого из отступов

```javascript
var bbox = [[-79, 43], [-73, 45]];
map.fitBounds(bbox, {
 padding: {top: 10, bottom:25, left: 15, right: 5}
});
```

#### Пример задания отступа `20px` для всех сторон

```javascript
var bbox = [[-79, 43], [-73, 45]];
map.fitBounds(bbox, {
 padding: 20
});
```

## RequestParameters (группа параметров)

Объект `RequestParameters`, который должен быть возвращен `callback`'ом переданым в `Map.options.transformRequest`.

Путь до файла в библиотеке: `src/ui/ajax.js`

Параметры:

- `url:string` — URL запроса;
- `headers:object` — заголовки, отправляемые с запросом;
- `method:string` — метод запроса: `GET`, `POST` или `PUT`;
- `type:string` — возвращаемый тип тела запроса (`body response`): `string`, `json` или `arrayBuffer`;
- `credentials:string` — `same-origin` или `include`. Используйте `include` для отправки кук (`cookies`) в кроссдоменных запросах;
- `collectResourceTiming:boolean` — Если `true`, то информация `Resource Timing API` будет доступна для запросов, выполняемых `GeoJSON` и `Vector Tile` (эта информация обычно недоступна из основного потока `JavaScript`). Информация будет возвращена в свойстве `ResourceTiming`.

#### Пример

```javascript
transformRequest: function(url, resourceType) {
 if (resourceType === 'Source' && url.indexOf('http://myHost') > -1) {
 return {
 url: url.replace('http', 'https'),
 headers: { 'my-custom-header': true },
 credentials: 'include' // Include cookies for cross-origin requests
        }
    }
};
```

## StyleImageInterface (спецификация)

Это не метод и не класс. Интерфейс для динамически генерируемых изображений.

Изображения, реализующие этот интерфейс, могут быть перерисованы для каждого кадра. Их можно использовать для анимации значков и узоров или для того, чтобы они реагировали на вводимые пользователем данные. Изображения могут реализовывать метод `StyleImageInterface#render`. Этот метод вызывается покадрово.

Путь до файла в библиотеке: `src/style/style_image.js`

Параметры:

- `width:number` — ширина изображения;
- `height:number` — высота изображения;
- `data:(Uint8Array|Uint8ClampedArray)` — массив байтов, представляющий изображение. Чтобы обеспечить пространство для всех четырех каналов в цвете RGBA, размер должен быть `width` × height × 4`.

#### Пример

```javascript
var flashingSquare = {
 width: 64,
 height: 64,
 data: new Uint8Array(64 * 64 * 4),

 onAdd: function(map) {
 this.map = map;
    },

 render: function() {
 // keep repainting while the icon is on the map
 this.map.triggerRepaint();

 // alternate between black and white based on the time
 var value = Math.round(Date.now() / 1000) % 2 === 0  ? 255 : 0;

 // check if image needs to be changed
 if (value !== this.previousValue) {
 this.previousValue = value;

 var bytesPerPixel = 4;
 for (var x = 0; x < this.width; x++) {
 for (var y = 0; y < this.height; y++) {
 var offset = (y * this.width + x) * bytesPerPixel;
 this.data[offset + 0] = value;
 this.data[offset + 1] = value;
 this.data[offset + 2] = value;
 this.data[offset + 3] = 255;
                }
            }

 // return true to indicate that the image changed
 return true;
        }
    }
}

map.addImage('flashing_square', flashingSquare);
```

## CustomLayerInterface (спецификация)

Это не метод и не класс. Интерфейс для кастомизации стиля слоев.

Кастомные слои позволяют пользователю визуализировать непосредственно в `GL context` карты с помощью камеры. Эти слои могут быть добавлены между любыми обычными слоями с помощью `Map#addLayer`.

Кастомные слои должны иметь уникальный идентификатор и тип `custom`. Они должны реализовывать `render` и могут реализовывать `prerender`, `onAdd` и `onRemove`. Они могут инициировать рендеринг с помощью `Map#triggerRepaint` и должны соответствующим образом обрабатывать `Map.event:webglcontextlost` и `Map.event:webglcontextrestored`.

Свойство `RenderingMode` определяет, будет ли слой обрабатываться как слой `2d` или `3d` карты:

- `"RenderingMode": "3d"` — для использования буфера глубины и совместного использования его с другими слоями;
- `"RenderingMode": "2d"` — для добавления слоя без глубины. Если вам нужно использовать буфер глубины для `2d` слоя, вы должны использовать закадровый фреймбуфер и `CustomLayerInterface#prerender`.

Путь до файла в библиотеке: `src/style/style_layer/custom_style_layer.js`

Параметры:

- `id:string` — уникальный идентификатор слоя;
- `type:string` — тип слоя, должен быть `custom`;
- `renderingMode:string` — `3d` или `2d`, по умолчанию `2d`.

#### Пример

```javascript
// Custom layer implemented as ES6 class
class NullIslandLayer {
 constructor() {
 this.id = 'null-island';
 this.type = 'custom';
 this.renderingMode = '2d';
    }

 onAdd(map, gl) {
 const vertexSource = `
            uniform mat4 u_matrix;
            void main() {
                gl_Position = u_matrix * vec4(0.5, 0.5, 0.0, 1.0);
                gl_PointSize = 20.0;
            }`;

 const fragmentSource = `
            void main() {
                gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
            }`;

 const vertexShader = gl.createShader(gl.VERTEX_SHADER);
        gl.shaderSource(vertexShader, vertexSource);
        gl.compileShader(vertexShader);
 const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
        gl.shaderSource(fragmentShader, fragmentSource);
        gl.compileShader(fragmentShader);

 this.program = gl.createProgram();
        gl.attachShader(this.program, vertexShader);
        gl.attachShader(this.program, fragmentShader);
        gl.linkProgram(this.program);
    }

 render(gl, matrix) {
        gl.useProgram(this.program);
        gl.uniformMatrix4fv(gl.getUniformLocation(this.program, "u_matrix"), false, matrix);
        gl.drawArrays(gl.POINTS, 0, 1);
    }
}

map.on('load', function() {
    map.addLayer(new NullIslandLayer());
});
```

## prewarm

Выполняет «прогрев» всех ресурсов (например, инициализирует веб-воркеры), чтобы снизить время на загрузки карты. Если используются `mmrgl.workerUrl` и `mmrgl.workerCount`, то их нужно определять до вызова `prewarm()`.

По умолчанию управление этими ресурсами выполняется автоматически, и они инициализируются по необходимости (лениво) при первом создании карты. При вызове `prewarm()` ресурсы будут созданы заранее и не будут очищены при удалении последней карты со страницы. Это позволяет повторно использовать их новыми экземплярами карт. Их можно очистить вручную, вызвав функцию `mmrgl.clearPrewarmedResources()`. Это необходимо только в том случае, если ваша веб-страница остается активной, но полностью перестает использовать карты.

Это полезно при использовании карт в одностраничном приложении (SPA), где пользователь будет перемещаться между различными страницами или экранами, которые могут привести к постоянному созданию и уничтожению экземпляров карт.

Путь до файла в библиотеке: `src/index.js`

#### Пример

```javascript
mmrgl.prewarm()
```

## clearPrewarmedResources

Очищает ресурсы, которые ранее были созданы `mmrgl.prewarm()`. Обратите внимание, что обычно в этом нет необходимости. Вы должны вызывать эту функцию только в том случае, если ожидаете, что пользователь вашего приложения не вернется к просмотру карты в любой момент вашего приложения.

Путь до файла в библиотеке: `src/index.js`

#### Пример

```javascript
mmrgl.clearPrewarmedResources()
```
