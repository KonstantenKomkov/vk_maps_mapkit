import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vk_maps_mapkit/vk_maps_mapkit.dart';

VkClusterItem _item(String id, double lat, double lon) =>
    VkClusterItem(id: id, position: VkLatLon(lat, lon));

void main() {
  const VkClusterizer clusterizer = VkClusterizer();

  group('VkClusterizer', () {
    test('далёкие точки не объединяются', () {
      final List<VkCluster> clusters = clusterizer.clusterize(<VkClusterItem>[
        _item('msk', 55.75, 37.62),
        _item('spb', 59.94, 30.31),
      ], zoom: 10);
      expect(clusters, hasLength(2));
      expect(clusters.every((VkCluster c) => c.isSingle), isTrue);
    });

    test('близкие точки объединяются, центр — среднее', () {
      final List<VkCluster> clusters = clusterizer.clusterize(<VkClusterItem>[
        _item('a', 55.7500, 37.6200),
        _item('b', 55.7502, 37.6204),
      ], zoom: 10);
      expect(clusters, hasLength(1));
      expect(clusters.single.count, 2);
      expect(clusters.single.position.latitude, closeTo(55.7501, 1e-6));
      expect(clusters.single.position.longitude, closeTo(37.6202, 1e-6));
    });

    test('на большом зуме те же точки расходятся', () {
      final List<VkClusterItem> points = <VkClusterItem>[
        _item('a', 55.7500, 37.6200),
        _item('b', 55.7502, 37.6204),
      ];
      expect(clusterizer.clusterize(points, zoom: 10), hasLength(1));
      expect(clusterizer.clusterize(points, zoom: 18), hasLength(2));
    });

    test('порядок результата устойчив между вызовами', () {
      final List<VkClusterItem> points = <VkClusterItem>[
        _item('a', 55.80, 37.60),
        _item('b', 55.70, 37.60),
        _item('c', 55.75, 37.60),
      ];
      final List<String> first = clusterizer
          .clusterize(points, zoom: 12)
          .map((VkCluster c) => c.items.first.id)
          .toList();
      final List<String> second = clusterizer
          .clusterize(points.reversed, zoom: 12)
          .map((VkCluster c) => c.items.first.id)
          .toList();
      expect(first, second);
    });

    test('пустой список даёт пустой результат', () {
      expect(
        clusterizer.clusterize(const <VkClusterItem>[], zoom: 10),
        isEmpty,
      );
    });

    test('радиус влияет на группировку', () {
      final List<VkClusterItem> points = <VkClusterItem>[
        _item('a', 55.750, 37.620),
        _item('b', 55.754, 37.628),
      ];
      expect(
        const VkClusterizer(radiusPixels: 10).clusterize(points, zoom: 12),
        hasLength(2),
      );
      expect(
        const VkClusterizer(radiusPixels: 400).clusterize(points, zoom: 12),
        hasLength(1),
      );
    });
  });

  group('GeoJSON кластеров', () {
    test('кластер несёт число точек, одиночка — свои свойства', () {
      final List<VkCluster> clusters = clusterizer.clusterize(<VkClusterItem>[
        VkClusterItem(
          id: 'single',
          position: VkLatLon(59.94, 30.31),
          properties: const <String, Object?>{'name': 'Питер'},
        ),
        _item('a', 55.7500, 37.6200),
        _item('b', 55.7502, 37.6204),
      ], zoom: 10);
      final Map<String, Object?> geoJson =
          jsonDecode(clusterizer.toGeoJson(clusters)) as Map<String, Object?>;
      final List<Object?> features = geoJson['features']! as List<Object?>;

      final Map<String, Object?> clusterFeature = features
          .cast<Map<String, Object?>>()
          .firstWhere(
            (Map<String, Object?> f) =>
                (f['properties']! as Map<String, Object?>)['cluster'] == true,
          );
      expect(
        (clusterFeature['properties']! as Map<String, Object?>)['point_count'],
        2,
      );

      final Map<String, Object?> singleFeature = features
          .cast<Map<String, Object?>>()
          .firstWhere(
            (Map<String, Object?> f) =>
                (f['properties']! as Map<String, Object?>)['id'] == 'single',
          );
      expect(
        (singleFeature['properties']! as Map<String, Object?>)['name'],
        'Питер',
      );
    });

    test('большие числа сокращаются', () {
      final List<VkClusterItem> many = <VkClusterItem>[
        for (int i = 0; i < 1200; i++)
          _item('p$i', 55.75 + i * 1e-7, 37.62 + i * 1e-7),
      ];
      final String geoJson = clusterizer.toGeoJson(
        clusterizer.clusterize(many, zoom: 10),
      );
      expect(geoJson, contains('"point_count_abbreviated":"1k+"'));
    });

    test('координаты в GeoJSON идут как [lon, lat]', () {
      final String geoJson = clusterizer.toGeoJson(
        clusterizer.clusterize(<VkClusterItem>[
          _item('a', 55.75, 37.62),
        ], zoom: 10),
      );
      expect(geoJson, contains('[37.62,55.75]'));
    });
  });
}
