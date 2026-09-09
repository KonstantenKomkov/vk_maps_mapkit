import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';
import 'package:vk_maps_mapkit_web/src/conversions.dart';

void main() {
  group('стиль', () {
    test('готовые стили превращаются в ссылки SDK', () {
      expect(
        VkWebConversions.styleToJs(
          const VkMapStyle.predefined(VkPredefinedStyle.main),
        ),
        'mmr://api/styles/main_style.json',
      );
      expect(
        VkWebConversions.styleToJs(
          const VkMapStyle.predefined(VkPredefinedStyle.dark),
        ),
        'mmr://api/styles/dark_style.json',
      );
    });

    test('стиль, которого нет в web-SDK, отвергается явной ошибкой', () {
      expect(
        () => VkWebConversions.styleToJs(
          const VkMapStyle.predefined(VkPredefinedStyle.navigationMain),
        ),
        throwsUnsupportedError,
      );
    });

    test('ссылка передаётся строкой', () {
      expect(
        VkWebConversions.styleToJs(
          VkMapStyle.url(Uri.parse('https://example.com/style.json')),
        ),
        'https://example.com/style.json',
      );
    });

    test('JSON передаётся разобранным объектом', () {
      final Object style = VkWebConversions.styleToJs(
        const VkMapStyle.json('{"version":8,"layers":[]}'),
      );
      expect(style, isA<Map<String, Object?>>());
      expect((style as Map<String, Object?>)['version'], 8);
    });
  });

  group('камера', () {
    test('незаданные поля не попадают в параметры', () {
      final Map<String, Object?> options = VkWebConversions.cameraOptions(
        target: VkLatLon(55.75, 37.62),
        options: const VkCameraOptions(zoom: 12),
      );
      expect(options.keys, <String>['center', 'zoom']);
      expect(options['center'], <double>[37.62, 55.75]);
    });

    test('пустой набор изменений даёт пустые параметры', () {
      expect(VkWebConversions.cameraOptions(), isEmpty);
    });

    test('нулевая длительность отключает анимацию', () {
      expect(
        VkWebConversions.animationOptions(VkAnimationOptions.none),
        <String, Object?>{'animate': false, 'duration': 0},
      );
      expect(VkWebConversions.animationOptions(null), <String, Object?>{
        'animate': false,
        'duration': 0,
      });
    });

    test('анимация помечается существенной, чтобы её не пропустил браузер', () {
      final Map<String, Object?> options = VkWebConversions.animationOptions(
        const VkAnimationOptions(duration: Duration(milliseconds: 400)),
      );
      expect(options['duration'], 400);
      expect(options['essential'], isTrue);
    });

    test('границы идут парой «юго-запад, северо-восток»', () {
      final List<List<double>> bounds = VkWebConversions.bounds(
        VkLatLonBounds(
          southwest: VkLatLon(55.0, 37.0),
          northeast: VkLatLon(56.0, 38.0),
        ),
      );
      expect(bounds, <List<double>>[
        <double>[37.0, 55.0],
        <double>[38.0, 56.0],
      ]);
    });
  });

  group('маркеры', () {
    VkMarker marker(
      String id, {
      bool visible = true,
      VkMarkerAlignment alignment = VkMarkerAlignment.bottom,
      int zIndex = 0,
    }) => VkMarker(
      markerId: VkMarkerId(id),
      position: VkLatLon(55.75, 37.62),
      imageId: 'pin',
      alignment: alignment,
      zIndex: zIndex,
      visible: visible,
    );

    test('видимые маркеры превращаются в объекты коллекции', () {
      final Map<String, Object?> collection =
          VkWebConversions.markersFeatureCollection(<VkMarker>[
            marker('a', alignment: VkMarkerAlignment.topLeft, zIndex: 3),
          ]);
      final List<Object?> features = collection['features']! as List<Object?>;
      expect(features, hasLength(1));

      final Map<String, Object?> feature =
          features.single! as Map<String, Object?>;
      final Map<String, Object?> properties =
          feature['properties']! as Map<String, Object?>;
      expect(properties['markerId'], 'a');
      expect(properties['imageId'], 'pin');
      expect(properties['anchor'], 'top-left');
      expect(properties['zIndex'], 3);

      final Map<String, Object?> geometry =
          feature['geometry']! as Map<String, Object?>;
      expect(geometry['coordinates'], <double>[37.62, 55.75]);
    });

    test('невидимый маркер в коллекцию не попадает', () {
      final Map<String, Object?> collection =
          VkWebConversions.markersFeatureCollection(<VkMarker>[
            marker('a', visible: false),
            marker('b'),
          ]);
      expect(collection['features'], hasLength(1));
    });

    test('слой маркеров берёт картинку и привязку из свойств объекта', () {
      final Map<String, Object?> layer = VkWebConversions.markersLayer();
      final Map<String, Object?> layout =
          layer['layout']! as Map<String, Object?>;
      expect(layer['type'], 'symbol');
      expect(layer['source'], VkWebConversions.markersSourceId);
      expect(layout['icon-image'], <Object?>['get', 'imageId']);
      expect(layout['icon-anchor'], <Object?>['get', 'anchor']);
      expect(layout['icon-allow-overlap'], isTrue);
    });

    test('все точки привязки имеют имя из спецификации стиля', () {
      const Set<String> allowed = <String>{
        'center',
        'top',
        'bottom',
        'left',
        'right',
        'top-left',
        'top-right',
        'bottom-left',
        'bottom-right',
      };
      for (final VkMarkerAlignment alignment in VkMarkerAlignment.values) {
        expect(allowed, contains(VkWebConversions.markerAnchor(alignment)));
      }
    });
  });

  group('индикатор пользователя', () {
    test('без координат коллекция пустая', () {
      expect(
        VkWebConversions.userLocationFeatureCollection(null)['features'],
        isEmpty,
      );
    });

    test('направление попадает в свойства точки', () {
      final Map<String, Object?> collection =
          VkWebConversions.userLocationFeatureCollection(
            VkLatLon(55.75, 37.62),
            bearing: 90,
          );
      final Map<String, Object?> feature =
          (collection['features']! as List<Object?>).single!
              as Map<String, Object?>;
      expect((feature['properties']! as Map<String, Object?>)['bearing'], 90);
    });

    test('круг точности рисуется только при положительной точности', () {
      final Map<String, Object?> empty =
          jsonDecode(
                VkWebConversions.userAccuracyGeoJson(
                  VkLatLon(55.75, 37.62),
                  null,
                ),
              )
              as Map<String, Object?>;
      expect(empty['features'], isEmpty);

      final Map<String, Object?> circle =
          jsonDecode(
                VkWebConversions.userAccuracyGeoJson(
                  VkLatLon(55.75, 37.62),
                  50,
                ),
              )
              as Map<String, Object?>;
      expect(circle['type'], 'Feature');
      expect((circle['geometry']! as Map<String, Object?>)['type'], 'Polygon');
    });
  });

  group('прочее', () {
    test('отступы раскладываются по сторонам', () {
      expect(
        VkWebConversions.padding(
          const VkEdgeInsets(left: 1, top: 2, right: 3, bottom: 4),
        ),
        <String, Object?>{'top': 2.0, 'bottom': 4.0, 'left': 1.0, 'right': 3.0},
      );
    });

    test('углы логотипа совпадают с позициями элементов управления', () {
      expect(
        VkWebConversions.controlPosition(VkLogoAlignment.bottomRight),
        'bottom-right',
      );
      expect(
        VkWebConversions.controlPosition(VkLogoAlignment.topLeft),
        'top-left',
      );
    });

    test('источник GeoJSON собирается с разобранными данными', () {
      final Map<String, Object?> source = VkWebConversions.geoJsonSource(
        VkGeoJson.points(<VkLatLon>[VkLatLon(55.75, 37.62)]),
      );
      expect(source['type'], 'geojson');
      expect(source['data'], isA<Map<String, Object?>>());
    });
  });

  group('данные для SDK', () {
    // Структуры уезжают в карту через `JSON.parse`, поэтому всё, что здесь
    // собирается, обязано кодироваться в JSON без потерь: непригодное
    // значение когда-то уже утекло в карту сырым объектом Dart, и SDK
    // молча выбросил такие данные.
    test('коллекция маркеров кодируется в JSON целиком', () {
      final String encoded = jsonEncode(
        VkWebConversions.markersFeatureCollection(<VkMarker>[
          VkMarker(
            markerId: const VkMarkerId('m1'),
            position: VkLatLon(55.75, 37.62),
            imageId: 'pin',
          ),
        ]),
      );
      final Map<String, Object?> decoded =
          jsonDecode(encoded) as Map<String, Object?>;
      final Map<String, Object?> feature =
          (decoded['features']! as List<Object?>).single!
              as Map<String, Object?>;
      expect(feature['type'], 'Feature');
      expect(feature.keys, <String>['type', 'properties', 'geometry']);
    });

    test('слои и источники кодируются в JSON', () {
      expect(
        () => jsonEncode(VkWebConversions.markersLayer()),
        returnsNormally,
      );
      expect(
        () => jsonEncode(VkWebConversions.userLocationLayer()),
        returnsNormally,
      );
      expect(
        () => jsonEncode(VkWebConversions.userAccuracyLayer()),
        returnsNormally,
      );
      expect(
        () => jsonEncode(
          VkWebConversions.geoJsonSource(
            VkGeoJson.points(<VkLatLon>[VkLatLon(55.75, 37.62)]),
          ),
        ),
        returnsNormally,
      );
    });

    test('параметры камеры и анимации кодируются в JSON', () {
      expect(
        () => jsonEncode(<String, Object?>{
          ...VkWebConversions.cameraOptions(
            target: VkLatLon(55.75, 37.62),
            options: const VkCameraOptions(
              zoom: 12,
              padding: VkEdgeInsets.all(8),
            ),
          ),
          ...VkWebConversions.animationOptions(
            const VkAnimationOptions(duration: Duration(milliseconds: 300)),
          ),
        }),
        returnsNormally,
      );
    });
  });

  group('недостающие изображения стиля', () {
    VkMarker marker(String id, String imageId) => VkMarker(
      markerId: VkMarkerId(id),
      position: VkLatLon(55.75, 37.62),
      imageId: imageId,
    );

    test('картинка маркера, которой нет в стиле, — повод сообщить', () {
      expect(
        VkWebConversions.shouldReportMissingImage(
          'pin',
          markers: <VkMarker>{marker('a', 'pin')},
          addedImages: const <String>[],
        ),
        isTrue,
      );
    });

    test('иконки самого стиля приложение не касаются', () {
      // Стиль VK просит свои значки (организации, знаки) тем же событием.
      expect(
        VkWebConversions.shouldReportMissingImage(
          'recycling',
          markers: <VkMarker>{marker('a', 'pin')},
          addedImages: const <String>[],
        ),
        isFalse,
      );
    });

    test('про добавленную приложением картинку не сообщаем', () {
      expect(
        VkWebConversions.shouldReportMissingImage(
          'pin',
          markers: <VkMarker>{marker('a', 'pin')},
          addedImages: const <String>['pin'],
        ),
        isFalse,
      );
    });

    test('без маркеров сообщать не о чем', () {
      expect(
        VkWebConversions.shouldReportMissingImage(
          'pin',
          markers: const <VkMarker>{},
          addedImages: const <String>[],
        ),
        isFalse,
      );
    });
  });
}
