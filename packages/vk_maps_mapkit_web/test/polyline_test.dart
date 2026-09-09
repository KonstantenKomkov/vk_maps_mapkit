import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';
import 'package:vk_maps_mapkit_web/src/polyline.dart';

void main() {
  group('декодер ломаной', () {
    test('разбирает пример со стандартной точностью 1e5', () {
      // Классический пример из описания формата: три точки.
      final List<VkLatLon> points = VkWebPolyline.decode(
        '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
        precision: 1e5,
      );
      expect(points, hasLength(3));
      expect(points.first.latitude, closeTo(38.5, 1e-5));
      expect(points.first.longitude, closeTo(-120.2, 1e-5));
      expect(points.last.latitude, closeTo(43.252, 1e-5));
      expect(points.last.longitude, closeTo(-126.453, 1e-5));
    });

    test('по умолчанию использует точность VK Карт — 1e6', () {
      final List<VkLatLon> points = VkWebPolyline.decode(
        '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
      );
      expect(points.first.latitude, closeTo(3.85, 1e-6));
    });

    test('обрыв строки — это ошибка формата, а не молчаливый результат', () {
      expect(
        () => VkWebPolyline.decode('_p~iF~ps|U_ulL'.substring(0, 6)),
        throwsFormatException,
      );
    });

    test('пустая строка даёт пустой список', () {
      expect(VkWebPolyline.decode(''), isEmpty);
    });

    test('ломаная превращается в GeoJSON-объект LineString', () {
      final Map<String, Object?> geoJson =
          jsonDecode(
                VkWebPolyline.toGeoJson(
                  '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
                  precision: 1e5,
                ),
              )
              as Map<String, Object?>;
      final Map<String, Object?> geometry =
          geoJson['geometry']! as Map<String, Object?>;
      expect(geometry['type'], 'LineString');
      expect(geometry['coordinates'], hasLength(3));
      // Порядок координат в GeoJSON — долгота, широта.
      expect((geometry['coordinates']! as List<Object?>).first, <double>[
        -120.2,
        38.5,
      ]);
    });
  });
}
