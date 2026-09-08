import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';

Map<String, Object?> _decode(String json) =>
    jsonDecode(json) as Map<String, Object?>;

void main() {
  group('VkStyleLayer', () {
    test('линия сериализуется по спецификации Mapbox Style', () {
      const VkStyleLayer layer = VkStyleLayer.line(
        id: 'route',
        sourceId: 'route-source',
        paint: <String, Object?>{'line-color': '#0077FF', 'line-width': 6},
        layout: <String, Object?>{'line-cap': 'round'},
      );
      final Map<String, Object?> json = layer.toJson();

      expect(json['id'], 'route');
      expect(json['type'], 'line');
      expect(json['source'], 'route-source');
      expect((json['paint']! as Map<String, Object?>)['line-width'], 6);
      expect((json['layout']! as Map<String, Object?>)['line-cap'], 'round');
    });

    test('пустые paint и layout в JSON не попадают', () {
      const VkStyleLayer layer = VkStyleLayer.fill(
        id: 'zone',
        sourceId: 'zone-source',
      );
      expect(layer.toJson().containsKey('paint'), isFalse);
      expect(layer.toJson().containsKey('layout'), isFalse);
    });

    test('фильтр и границы зума сохраняются', () {
      const VkStyleLayer layer = VkStyleLayer.circle(
        id: 'points',
        sourceId: 'src',
        filter: <Object?>['==', 'type', 'poi'],
        minZoom: 5,
        maxZoom: 18,
      );
      final Map<String, Object?> json = layer.toJson();
      expect(json['filter'], <Object?>['==', 'type', 'poi']);
      expect(json['minzoom'], 5);
      expect(json['maxzoom'], 18);
    });

    test('слои с одинаковым описанием равны', () {
      const VkStyleLayer a = VkStyleLayer.symbol(id: 'a', sourceId: 's');
      const VkStyleLayer b = VkStyleLayer.symbol(id: 'a', sourceId: 's');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('VkGeoJson', () {
    test('ломаная содержит точки в порядке [lon, lat]', () {
      final String json = VkGeoJson.lineString(<VkLatLon>[
        VkLatLon(55.0, 37.0),
        VkLatLon(56.0, 38.0),
      ]);
      final Map<String, Object?> decoded = _decode(json);
      final List<Object?> coordinates =
          (decoded['geometry']! as Map<String, Object?>)['coordinates']!
              as List<Object?>;

      expect(coordinates.first, <double>[37.0, 55.0]);
      expect(coordinates.last, <double>[38.0, 56.0]);
    });

    test('полигон замыкается автоматически', () {
      final String json = VkGeoJson.polygon(<VkLatLon>[
        VkLatLon(55.0, 37.0),
        VkLatLon(55.0, 38.0),
        VkLatLon(56.0, 38.0),
      ]);
      final List<Object?> ring =
          ((_decode(json)['geometry']! as Map<String, Object?>)['coordinates']!
                      as List<Object?>)
                  .first!
              as List<Object?>;

      expect(ring, hasLength(4));
      expect(ring.first, ring.last);
    });

    test('уже замкнутый полигон не удваивает точку', () {
      final VkLatLon start = VkLatLon(55.0, 37.0);
      final String json = VkGeoJson.polygon(<VkLatLon>[
        start,
        VkLatLon(55.0, 38.0),
        VkLatLon(56.0, 38.0),
        start,
      ]);
      final List<Object?> ring =
          ((_decode(json)['geometry']! as Map<String, Object?>)['coordinates']!
                      as List<Object?>)
                  .first!
              as List<Object?>;
      expect(ring, hasLength(4));
    });

    test('круг даёт замкнутый контур нужного размера', () {
      final String json = VkGeoJson.circle(
        VkLatLon(55.75, 37.62),
        1000,
        steps: 8,
      );
      final List<Object?> ring =
          ((_decode(json)['geometry']! as Map<String, Object?>)['coordinates']!
                      as List<Object?>)
                  .first!
              as List<Object?>;

      // Восемь сегментов плюс замыкающая точка.
      expect(ring, hasLength(9));
      final List<Object?> east = ring.first! as List<Object?>;
      // Радиус в 1 км по долготе на широте Москвы — примерно 0.016°.
      expect((east[0]! as double) - 37.62, closeTo(0.016, 0.002));
    });

    test('круг из двух сегментов отклоняется', () {
      expect(
        () => VkGeoJson.circle(VkLatLon(55, 37), 100, steps: 2),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('точки собираются со свойствами', () {
      final String json = VkGeoJson.points(<VkLatLon>[
        VkLatLon(55.0, 37.0),
        VkLatLon(56.0, 38.0),
      ], properties: (int index) => <String, Object?>{'index': index});
      final List<Object?> features =
          _decode(json)['features']! as List<Object?>;
      expect(features, hasLength(2));
      expect(
        ((features.last! as Map<String, Object?>)['properties']!
            as Map<String, Object?>)['index'],
        1,
      );
    });
  });
}
