import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vk_maps_mapkit/vk_maps_mapkit.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart'
    show VkMapsPlatform;

import 'fake_vk_maps_platform.dart';

void main() {
  late FakeVkMapsPlatform platform;
  late VkMapController controller;

  setUp(() async {
    platform = FakeVkMapsPlatform();
    VkMapsPlatform.instance = platform;
    controller = VkMapController(1);
  });

  tearDown(() async {
    await platform.close();
  });

  group('рецепты рисования', () {
    test('маршрут создаёт источник и линию один раз', () async {
      await controller.drawRoute('ydqliBeqcrfA_KyO');
      expect(platform.calls, <String>[
        'addEncodedPolylineSource(1, route-source)',
        'addLayer(1, route, before: null)',
      ]);
      expect(platform.lastLayer!.type, 'line');
      expect(platform.lastLayer!.paint['line-color'], '#0077FF');
    });

    test('повторный маршрут обновляет геометрию, не создавая слой', () async {
      await controller.drawRoute('ydqliBeqcrfA');
      platform.calls.clear();
      await controller.drawRoute('ydqliBeqcrfA_KyO');

      expect(platform.calls, <String>[
        'addEncodedPolylineSource(1, route-source)',
      ]);
    });

    test('полигон рисуется заливкой с замкнутым контуром', () async {
      await controller.drawPolygon(
        <VkLatLon>[
          VkLatLon(55.0, 37.0),
          VkLatLon(55.0, 38.0),
          VkLatLon(56.0, 38.0),
        ],
        id: 'zone',
        outlineColor: '#FF0000',
      );

      expect(platform.calls, contains('addGeoJsonSource(1, zone-source)'));
      expect(platform.lastLayer!.type, 'fill');
      expect(platform.lastLayer!.paint['fill-outline-color'], '#FF0000');

      final Map<String, Object?> geoJson =
          jsonDecode(platform.lastGeoJson!) as Map<String, Object?>;
      final List<Object?> ring =
          ((geoJson['geometry']! as Map<String, Object?>)['coordinates']!
                      as List<Object?>)
                  .first!
              as List<Object?>;
      expect(ring.first, ring.last);
    });

    test('повторный полигон меняет данные источника', () async {
      await controller.drawPolygon(<VkLatLon>[
        VkLatLon(55.0, 37.0),
        VkLatLon(55.0, 38.0),
        VkLatLon(56.0, 38.0),
      ]);
      platform.calls.clear();
      await controller.drawPolygon(<VkLatLon>[
        VkLatLon(55.0, 37.0),
        VkLatLon(55.0, 39.0),
        VkLatLon(56.0, 39.0),
      ]);

      expect(platform.calls, <String>[
        'setGeoJsonSourceData(1, polygon-source)',
      ]);
    });

    test('круг считается на Dart-стороне и рисуется заливкой', () async {
      await controller.drawCircle(VkLatLon(55.75, 37.62), 500, steps: 12);

      expect(platform.calls.first, 'addGeoJsonSource(1, circle-source)');
      final Map<String, Object?> geoJson =
          jsonDecode(platform.lastGeoJson!) as Map<String, Object?>;
      final List<Object?> ring =
          ((geoJson['geometry']! as Map<String, Object?>)['coordinates']!
                      as List<Object?>)
                  .first!
              as List<Object?>;
      expect(ring, hasLength(13));
    });

    test('удаление рецепта убирает слой и источник', () async {
      await controller.drawRoute('ydqliBeqcrfA');
      platform.calls.clear();
      await controller.removeDrawing('route');

      expect(platform.calls, <String>[
        'removeLayer(1, route)',
        'removeSource(1, route-source)',
      ]);
    });

    test('удаление того, чего не рисовали, ничего не делает', () async {
      await controller.removeDrawing('нет-такого');
      expect(platform.calls, isEmpty);
    });

    test('слой можно вставить под существующий', () async {
      await controller.drawRoute('ydqliBeqcrfA', beforeLayerId: 'labels');
      expect(platform.calls, contains('addLayer(1, route, before: labels)'));
    });
  });

  group('слои и источники напрямую', () {
    test('видимость слоя переключается', () async {
      await controller.setLayerVisibility('route', visible: false);
      expect(platform.calls, <String>['setLayerVisibility(1, route, false)']);
    });

    test('GeoJSON кластеров кладётся в источник', () async {
      const VkClusterizer clusterizer = VkClusterizer();
      final String geoJson = clusterizer.toGeoJson(
        clusterizer.clusterize(<VkClusterItem>[
          VkClusterItem(id: 'a', position: VkLatLon(55.75, 37.62)),
        ], zoom: 12),
      );
      await controller.addGeoJsonSource('clusters', geoJson);

      expect(platform.calls, <String>['addGeoJsonSource(1, clusters)']);
      expect(platform.lastGeoJson, contains('FeatureCollection'));
    });
  });
}
