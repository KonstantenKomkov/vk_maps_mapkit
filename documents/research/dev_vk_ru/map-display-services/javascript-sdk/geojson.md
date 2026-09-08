<!-- Источник: https://dev.vk.ru/ru/vkmaps/map-display-services/javascript-sdk/geojson -->
<!-- Снято: 2026-09-08 -->

# Добавление объектов с использованием GeoJSON

Вы можете использовать `GeoJSON` для добавления слоя с различными объектами и описанием их оформления.

## Гексагоны

![Пример отображения гексагонов на карте](https://sun9-1.vkuserphoto.ru/jmwUrGBhzuJm2zEJIoB--46X6rlBQxhVB1TU7A/Cr0tYq4189w.jpg)Пример отображения гексагонов на карте

### Пример кода, нужно разместить в `index.js`

```javascript
map.addControl(new mmrgl.NavigationControl());

map.on('load', () => {
 // добавьте GeoJSON с данными
  map.addSource('hexagon', {
 'type': 'geojson',
 'data': 'hexagons.geojson', // файл прикреплен к документу
  });

 // Опишите правило для отображения гексагонов
  map.addLayer({
 'id': 'hexagon-fill',
 'type': 'fill',
 'source': 'hexagon',
 'layout': {},
 'paint': {
 'fill-color': ['get', 'hexcolor'],
 'fill-opacity': 0.5
    }
  });
})
```

[Скачать пример файла](https://vk.ru/away.php?to=https%3A%2F%2Fcloud.mail.ru%2Fpublic%2FoHvS%2F51UNj9q5E)
