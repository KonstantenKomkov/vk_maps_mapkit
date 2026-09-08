<!-- Источник: https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/quickstart -->
<!-- Снято: 2026-09-08 -->

# Быстрый старт

`MMR GL JS` — JavaScript библиотека, которая использует WebGL для рендеринга интерактивных карт.

Пример карты [https://tiles.maps.vk.com/](https://vk.ru/away.php?to=https%3A%2F%2Ftiles.maps.vk.com%2F)

## Подключение на HTML-страницу

Необходимо добавить `<script>` и `<link>` в теге `<head>`.

### Пример

```html
<head>
  ...
 <script src="https://maps.vk.com/sdk/js/<version>/mmr-gl.js"></script>
 <link href="https://maps.vk.com/sdk/js/<version>/mmr-gl.css" rel="stylesheet">
  ...
</head>
```

Рекомендуется использовать самую свежую версию SDK.
Для получения последней версии SDK можно указать `0` или `0.0` вместо точной версии, таким образом будет загружена последняя актуальная версия с номером `0.x.x` либо `0.0.x` соответственно.

### Пример кода для инициализации карты

```html
<div id="map" style="width: 800px; height: 600px;"></div>
<script>
  mmrgl.accessToken = 'Token';
 var map = new mmrgl.Map({
 container: 'map',
 zoom: 8,
 center: [37.6165, 55.7505],
 style: 'mmr://api/styles/main_style.json',
 hash: true
  });
</script>
```

## Установка через npm

Устанавливаем пакет с помощью команды из примера.

`$~ npm install mmr-gl`

### Пример кода на React для инициализации карты

```javascript
import mmrgl from 'mmr-gl';
import { useEffect } from 'react'

import 'mmr-gl/dist/mmr-gl.css';

export function Map() {
  useEffect( () => {
    mmrgl.accessToken = 'accessToken';

 const map = new mmrgl.Map({
 container: 'map',
 zoom: 8,
 center: [37.6165, 55.7505],
 style: 'mmr://api/styles/main_style.json',
 hash: true,
    })

 return () => {
 if (map) map.remove();
    }
  }

 return <div id="map" style={{ width: '800px', height: '600px'}} />
}
```

## Детальная информация

Более подробную информацию по использованию `MMR GL JS` SDK вы найдёте в разделах:

- Карта
- Свойства и опции
- Метки и элементы управления
- География и геометрия
- Handlers (обработчики)
- Sources (источники)
- Events (события)
- Использование в React приложениях
- Объединение точек в кластеры
- Добавление объектов с использованием GeoJSON
- Описание дополнительных объектов карты
