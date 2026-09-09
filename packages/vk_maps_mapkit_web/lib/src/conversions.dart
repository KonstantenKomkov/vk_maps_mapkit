import 'dart:convert';

import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';

/// Перевод типов контракта в структуры MMR GL JS.
///
/// Здесь нет ни одного обращения к JavaScript: функции возвращают обычные
/// коллекции Dart, которые слой interop превращает в JS-объекты. Так эту
/// часть можно покрыть тестами без браузера.
abstract final class VkWebConversions {
  /// Идентификатор источника, в котором лежат маркеры карты.
  static const String markersSourceId = 'vk-maps-mapkit-markers';

  /// Идентификатор слоя, которым рисуются маркеры.
  static const String markersLayerId = 'vk-maps-mapkit-markers';

  /// Идентификатор источника с кругом точности индикатора пользователя.
  static const String userAccuracySourceId = 'vk-maps-mapkit-user-accuracy';

  /// Идентификатор источника с точкой индикатора пользователя.
  static const String userLocationSourceId = 'vk-maps-mapkit-user-location';

  /// Идентификатор слоя круга точности.
  static const String userAccuracyLayerId = 'vk-maps-mapkit-user-accuracy';

  /// Идентификатор слоя точки пользователя.
  static const String userLocationLayerId = 'vk-maps-mapkit-user-location';

  /// Ссылка на готовый стиль из состава SDK.
  ///
  /// В JavaScript SDK стиль задаётся ссылкой вида
  /// `mmr://api/styles/main_style.json`. Документация web-SDK перечисляет
  /// `light`, `dark` и `main`, а страница «Стили карт» показывает ещё
  /// `simple`. Остальных стилей мобильных SDK в web нет — вместо тихой
  /// подмены на похожий бросается ошибка.
  static String predefinedStyleUrl(VkPredefinedStyle style) => switch (style) {
    VkPredefinedStyle.main => 'mmr://api/styles/main_style.json',
    VkPredefinedStyle.dark => 'mmr://api/styles/dark_style.json',
    VkPredefinedStyle.simple => 'mmr://api/styles/simple_style.json',
    VkPredefinedStyle.grayLight ||
    VkPredefinedStyle.simpleDark ||
    VkPredefinedStyle.navigationMain ||
    VkPredefinedStyle.navigationDark => throw UnsupportedError(
      'Стиль ${style.name} на web недоступен: JavaScript SDK VK Карт '
      'документирует только main, dark и simple. Задайте стиль ссылкой '
      'или JSON через VkMapStyle.url / VkMapStyle.json.',
    ),
  };

  /// Значение параметра `style` карты.
  ///
  /// Возвращается либо строка (ссылка), либо разобранный JSON стиля —
  /// `Map#setStyle` принимает оба варианта.
  static Object styleToJs(VkMapStyle style) => switch (style) {
    VkPredefinedMapStyle(:final VkPredefinedStyle style) => predefinedStyleUrl(
      style,
    ),
    VkUrlMapStyle(:final Uri url) => url.toString(),
    VkJsonMapStyle(:final String json) => jsonDecode(json) as Object,
  };

  /// Точка в порядке, принятом в GeoJSON и в JavaScript SDK: долгота, широта.
  static List<double> lngLat(VkLatLon point) => <double>[
    point.longitude,
    point.latitude,
  ];

  /// Отступы в виде `PaddingOptions`.
  static Map<String, Object?> padding(VkEdgeInsets insets) => <String, Object?>{
    'top': insets.top,
    'bottom': insets.bottom,
    'left': insets.left,
    'right': insets.right,
  };

  /// Границы области в виде `LngLatBoundsLike`: юго-запад, северо-восток.
  static List<List<double>> bounds(VkLatLonBounds value) => <List<double>>[
    lngLat(value.southwest),
    lngLat(value.northeast),
  ];

  /// Параметры перемещения камеры — `CameraOptions`.
  ///
  /// Незаданные поля не попадают в результат: карта сохраняет текущее
  /// значение для всего, чего нет в объекте.
  static Map<String, Object?> cameraOptions({
    VkLatLon? target,
    VkCameraOptions? options,
  }) => <String, Object?>{
    if (target != null) 'center': lngLat(target),
    if (options?.zoom != null) 'zoom': options!.zoom,
    if (options?.bearing != null) 'bearing': options!.bearing,
    if (options?.pitch != null) 'pitch': options!.pitch,
    if (options?.padding != null) 'padding': padding(options!.padding!),
  };

  /// Параметры анимации — `AnimationOptions` без функции плавности.
  ///
  /// `essential: true` ставится всегда: иначе браузер с включённым
  /// «уменьшить движение» выполнит перемещение мгновенно, и обещанная
  /// контрактом длительность анимации перестанет соблюдаться.
  ///
  /// [VkAnimationDurationMode.atMost] на web совпадает с
  /// [VkAnimationDurationMode.exact]: `easeTo` всегда тратит ровно
  /// заданное время.
  static Map<String, Object?> animationOptions(VkAnimationOptions? animation) {
    if (animation == null || animation.duration == Duration.zero) {
      return <String, Object?>{'animate': false, 'duration': 0};
    }
    return <String, Object?>{
      'duration': animation.duration.inMilliseconds,
      'essential': true,
    };
  }

  /// Точка картинки маркера в терминах `icon-anchor`.
  static String markerAnchor(VkMarkerAlignment alignment) =>
      switch (alignment) {
        VkMarkerAlignment.center => 'center',
        VkMarkerAlignment.top => 'top',
        VkMarkerAlignment.bottom => 'bottom',
        VkMarkerAlignment.left => 'left',
        VkMarkerAlignment.right => 'right',
        VkMarkerAlignment.topLeft => 'top-left',
        VkMarkerAlignment.topRight => 'top-right',
        VkMarkerAlignment.bottomLeft => 'bottom-left',
        VkMarkerAlignment.bottomRight => 'bottom-right',
      };

  /// Угол размещения элемента управления: `top-left`, `bottom-right` и так
  /// далее.
  static String controlPosition(VkLogoAlignment alignment) =>
      switch (alignment) {
        VkLogoAlignment.topLeft => 'top-left',
        VkLogoAlignment.topRight => 'top-right',
        VkLogoAlignment.bottomLeft => 'bottom-left',
        VkLogoAlignment.bottomRight => 'bottom-right',
      };

  /// Маркеры в виде `FeatureCollection`.
  ///
  /// Невидимые маркеры в коллекцию не попадают: слой рисует всё, что в
  /// источнике, а отдельного признака видимости у объекта нет.
  static Map<String, Object?> markersFeatureCollection(
    Iterable<VkMarker> markers,
  ) => <String, Object?>{
    'type': 'FeatureCollection',
    'features': <Map<String, Object?>>[
      for (final VkMarker marker in markers)
        if (marker.visible)
          <String, Object?>{
            'type': 'Feature',
            'properties': <String, Object?>{
              'markerId': marker.markerId.value,
              'imageId': marker.imageId,
              'anchor': markerAnchor(marker.alignment),
              'zIndex': marker.zIndex,
            },
            'geometry': <String, Object?>{
              'type': 'Point',
              'coordinates': lngLat(marker.position),
            },
          },
    ],
  };

  /// Нужно ли жаловаться приложению на недостающее изображение стиля.
  ///
  /// Карта просит у стиля свои картинки — значки организаций, дорожные
  /// знаки и прочее, — и о нехватке любой из них шлёт то же событие. Это
  /// дело SDK и стиля, а не приложения: сообщаем только про картинки,
  /// на которые ссылаются маркеры, и только если приложение их не
  /// добавляло.
  static bool shouldReportMissingImage(
    String imageId, {
    required Iterable<VkMarker> markers,
    required Iterable<String> addedImages,
  }) {
    if (imageId.isEmpty || addedImages.contains(imageId)) {
      return false;
    }
    return markers.any((VkMarker marker) => marker.imageId == imageId);
  }

  /// Слой, которым рисуются маркеры.
  ///
  /// Картинка, точка привязки и порядок отрисовки берутся из свойств
  /// объекта, поэтому все маркеры карты укладываются в один слой.
  /// `icon-allow-overlap` включён: нативные SDK показывают маркеры все, а
  /// не прячут при наложении.
  static Map<String, Object?> markersLayer() => <String, Object?>{
    'id': markersLayerId,
    'type': 'symbol',
    'source': markersSourceId,
    'layout': <String, Object?>{
      'icon-image': <Object?>['get', 'imageId'],
      'icon-anchor': <Object?>['get', 'anchor'],
      'icon-allow-overlap': true,
      'icon-ignore-placement': true,
      'symbol-sort-key': <Object?>['get', 'zIndex'],
    },
  };

  /// Точка индикатора пользователя в виде `FeatureCollection`.
  static Map<String, Object?> userLocationFeatureCollection(
    VkLatLon? coordinates, {
    double? bearing,
  }) => <String, Object?>{
    'type': 'FeatureCollection',
    'features': <Map<String, Object?>>[
      if (coordinates != null)
        <String, Object?>{
          'type': 'Feature',
          'properties': <String, Object?>{'bearing': ?bearing},
          'geometry': <String, Object?>{
            'type': 'Point',
            'coordinates': lngLat(coordinates),
          },
        },
    ],
  };

  /// Круг точности индикатора пользователя.
  ///
  /// Круг считается многоугольником на Dart-стороне тем же кодом, что и на
  /// мобильных платформах, поэтому вид у него везде одинаковый.
  static String userAccuracyGeoJson(VkLatLon? coordinates, double? accuracy) {
    if (coordinates == null || accuracy == null || accuracy <= 0) {
      return jsonEncode(<String, Object?>{
        'type': 'FeatureCollection',
        'features': <Object?>[],
      });
    }
    return VkGeoJson.circle(coordinates, accuracy);
  }

  /// Слой круга точности.
  static Map<String, Object?> userAccuracyLayer() => <String, Object?>{
    'id': userAccuracyLayerId,
    'type': 'fill',
    'source': userAccuracySourceId,
    'paint': <String, Object?>{'fill-color': '#0077FF', 'fill-opacity': 0.15},
  };

  /// Слой точки пользователя.
  static Map<String, Object?> userLocationLayer() => <String, Object?>{
    'id': userLocationLayerId,
    'type': 'circle',
    'source': userLocationSourceId,
    'paint': <String, Object?>{
      'circle-radius': 7,
      'circle-color': '#0077FF',
      'circle-stroke-width': 3,
      'circle-stroke-color': '#FFFFFF',
    },
  };

  /// Источник GeoJSON, заданный строкой с данными.
  ///
  /// Строка разбирается здесь: `addSource` принимает объект, а не текст.
  static Map<String, Object?> geoJsonSource(String geoJson) =>
      <String, Object?>{'type': 'geojson', 'data': jsonDecode(geoJson)};

  /// Описание слоя стиля с подставленным источником.
  static Map<String, Object?> styleLayer(VkStyleLayer layer) => layer.toJson();
}
