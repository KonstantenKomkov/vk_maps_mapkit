import 'dart:convert';
import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';

/// Точка, участвующая в кластеризации.
@immutable
class VkClusterItem {
  /// Создаёт точку.
  const VkClusterItem({
    required this.id,
    required this.position,
    this.properties = const <String, Object?>{},
  });

  /// Идентификатор точки.
  final String id;

  /// Координата точки.
  final VkLatLon position;

  /// Произвольные свойства, попадающие в GeoJSON одиночных точек.
  final Map<String, Object?> properties;

  @override
  String toString() => 'VkClusterItem($id, $position)';
}

/// Группа точек, попавших в один кластер.
@immutable
class VkCluster {
  /// Создаёт кластер.
  const VkCluster({required this.position, required this.items});

  /// Центр кластера — среднее положение его точек.
  final VkLatLon position;

  /// Точки, вошедшие в кластер.
  final List<VkClusterItem> items;

  /// Сколько точек в кластере.
  int get count => items.length;

  /// Одиночная ли это точка.
  bool get isSingle => items.length == 1;

  @override
  String toString() => 'VkCluster($position, точек: $count)';
}

/// Сеточная кластеризация точек на стороне Dart.
///
/// В нативном SDK кластеризации нет (см. `docs/design-decisions.md`, находка
/// по кластерам), поэтому она считается здесь. Алгоритм простой и
/// предсказуемый: экран разбивается на сетку с ячейкой [radiusPixels], точки
/// в одной ячейке объединяются, центр кластера — среднее положение.
@immutable
class VkClusterizer {
  /// Создаёт кластеризатор.
  const VkClusterizer({this.radiusPixels = 80, this.tileSize = 512})
    : assert(radiusPixels > 0, 'Радиус должен быть положительным'),
      assert(tileSize > 0, 'Размер тайла должен быть положительным');

  /// Размер ячейки сетки в экранных пикселях.
  final double radiusPixels;

  /// Размер тайла карты в пикселях.
  final double tileSize;

  /// Группирует [items] для указанного [zoom].
  ///
  /// Алгоритм жадный: точки обходятся в устойчивом порядке, каждая
  /// непривязанная точка забирает к себе всех непривязанных соседей ближе
  /// [radiusPixels]. Сетка используется только как индекс для поиска
  /// соседей — на самой сетке кластеризовать нельзя: две близкие точки по
  /// разные стороны границы ячейки не объединились бы.
  List<VkCluster> clusterize(
    Iterable<VkClusterItem> items, {
    required double zoom,
  }) {
    final double worldSize = tileSize * math.pow(2, zoom);
    final List<VkClusterItem> ordered = items.toList()
      ..sort((VkClusterItem a, VkClusterItem b) {
        final int byLatitude = b.position.latitude.compareTo(
          a.position.latitude,
        );
        if (byLatitude != 0) {
          return byLatitude;
        }
        final int byLongitude = a.position.longitude.compareTo(
          b.position.longitude,
        );
        return byLongitude != 0 ? byLongitude : a.id.compareTo(b.id);
      });

    final List<_Point> projected = <_Point>[
      for (final VkClusterItem item in ordered)
        _project(item.position, worldSize),
    ];

    // Индекс: ячейка сетки → номера точек в ней.
    final Map<int, List<int>> index = <int, List<int>>{};
    for (int i = 0; i < projected.length; i++) {
      index.putIfAbsent(_cellKey(projected[i]), () => <int>[]).add(i);
    }

    final List<bool> taken = List<bool>.filled(ordered.length, false);
    final double squaredRadius = radiusPixels * radiusPixels;
    final List<VkCluster> clusters = <VkCluster>[];

    for (int i = 0; i < ordered.length; i++) {
      if (taken[i]) {
        continue;
      }
      taken[i] = true;
      final List<VkClusterItem> group = <VkClusterItem>[ordered[i]];
      double latitude = ordered[i].position.latitude;
      double longitude = ordered[i].position.longitude;

      for (final int neighbour in _neighbours(index, projected[i])) {
        if (taken[neighbour]) {
          continue;
        }
        final double dx = projected[neighbour].x - projected[i].x;
        final double dy = projected[neighbour].y - projected[i].y;
        if (dx * dx + dy * dy > squaredRadius) {
          continue;
        }
        taken[neighbour] = true;
        group.add(ordered[neighbour]);
        latitude += ordered[neighbour].position.latitude;
        longitude += ordered[neighbour].position.longitude;
      }

      clusters.add(
        VkCluster(
          position: group.length == 1
              ? group.single.position
              : VkLatLon(latitude / group.length, longitude / group.length),
          items: List<VkClusterItem>.unmodifiable(group),
        ),
      );
    }
    return List<VkCluster>.unmodifiable(clusters);
  }

  int _cellKey(_Point point) {
    final int x = (point.x / radiusPixels).floor();
    final int y = (point.y / radiusPixels).floor();
    // Пара координат в одно число: ключи ячеек нужны только для поиска.
    return x * 73856093 ^ y * 19349663;
  }

  Iterable<int> _neighbours(Map<int, List<int>> index, _Point point) sync* {
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        final List<int>? cell =
            index[_cellKey(
              _Point(point.x + dx * radiusPixels, point.y + dy * radiusPixels),
            )];
        if (cell != null) {
          yield* cell;
        }
      }
    }
  }

  /// Собирает GeoJSON из кластеров для источника карты.
  ///
  /// У кластеров в свойствах лежит `point_count`, у одиночных точек —
  /// их собственные свойства. По этому полю разводятся слои: круг с
  /// числом для кластеров и иконка для одиночек.
  String toGeoJson(List<VkCluster> clusters) {
    final List<Map<String, Object?>> features = <Map<String, Object?>>[
      for (final VkCluster cluster in clusters)
        <String, Object?>{
          'type': 'Feature',
          'properties': cluster.isSingle
              ? <String, Object?>{
                  'id': cluster.items.single.id,
                  ...cluster.items.single.properties,
                }
              : <String, Object?>{
                  'cluster': true,
                  'point_count': cluster.count,
                  'point_count_abbreviated': _abbreviate(cluster.count),
                },
          'geometry': <String, Object?>{
            'type': 'Point',
            'coordinates': <double>[
              cluster.position.longitude,
              cluster.position.latitude,
            ],
          },
        },
    ];
    return jsonEncode(<String, Object?>{
      'type': 'FeatureCollection',
      'features': features,
    });
  }

  static String _abbreviate(int count) =>
      count >= 1000 ? '${(count / 1000).floor()}k+' : '$count';

  _Point _project(VkLatLon position, double worldSize) {
    final double x = (position.longitude + 180) / 360 * worldSize;
    final double latitudeRadians = position.latitude * math.pi / 180;
    final double y =
        (1 -
            math.log(
                  math.tan(latitudeRadians) + 1 / math.cos(latitudeRadians),
                ) /
                math.pi) /
        2 *
        worldSize;
    return _Point(x, y);
  }
}

@immutable
class _Point {
  const _Point(this.x, this.y);

  final double x;
  final double y;
}
