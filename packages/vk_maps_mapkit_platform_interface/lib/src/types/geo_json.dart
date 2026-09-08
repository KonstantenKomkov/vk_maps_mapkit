import 'dart:convert';
import 'dart:math' as math;

import 'lat_lon.dart';

/// Сборка GeoJSON для источников карты.
///
/// Источники принимают GeoJSON строкой, поэтому плагин не тащит зависимость
/// на модель GeoJSON: нужные фигуры собираются здесь.
abstract final class VkGeoJson {
  /// Коллекция точек с произвольными свойствами.
  static String points(
    Iterable<VkLatLon> points, {
    Map<String, Object?> Function(int index)? properties,
  }) {
    final List<Map<String, Object?>> features = <Map<String, Object?>>[];
    int index = 0;
    for (final VkLatLon point in points) {
      features.add(<String, Object?>{
        'type': 'Feature',
        'properties': properties?.call(index) ?? <String, Object?>{},
        'geometry': <String, Object?>{
          'type': 'Point',
          'coordinates': <double>[point.longitude, point.latitude],
        },
      });
      index++;
    }
    return jsonEncode(<String, Object?>{
      'type': 'FeatureCollection',
      'features': features,
    });
  }

  /// Ломаная по списку точек.
  static String lineString(
    List<VkLatLon> points, {
    Map<String, Object?> properties = const <String, Object?>{},
  }) => jsonEncode(<String, Object?>{
    'type': 'Feature',
    'properties': properties,
    'geometry': <String, Object?>{
      'type': 'LineString',
      'coordinates': <List<double>>[
        for (final VkLatLon point in points)
          <double>[point.longitude, point.latitude],
      ],
    },
  });

  /// Многоугольник по внешнему контуру.
  ///
  /// Контур замыкается автоматически, если первая и последняя точки не
  /// совпадают: незамкнутый полигон часть движков рисует непредсказуемо.
  static String polygon(
    List<VkLatLon> ring, {
    Map<String, Object?> properties = const <String, Object?>{},
  }) {
    final List<VkLatLon> closed = <VkLatLon>[
      ...ring,
      if (ring.isNotEmpty && ring.first != ring.last) ring.first,
    ];
    return jsonEncode(<String, Object?>{
      'type': 'Feature',
      'properties': properties,
      'geometry': <String, Object?>{
        'type': 'Polygon',
        'coordinates': <List<List<double>>>[
          <List<double>>[
            for (final VkLatLon point in closed)
              <double>[point.longitude, point.latitude],
          ],
        ],
      },
    });
  }

  /// Круг радиусом [radiusMeters] вокруг [center], приближённый
  /// многоугольником из [steps] сегментов.
  ///
  /// Нативного круга нет ни на одной платформе, поэтому он считается здесь:
  /// так результат одинаков на Android и iOS.
  static String circle(
    VkLatLon center,
    double radiusMeters, {
    int steps = 64,
    Map<String, Object?> properties = const <String, Object?>{},
  }) {
    if (steps < 3) {
      throw ArgumentError.value(steps, 'steps', 'Нужно хотя бы три сегмента');
    }
    const double earthRadius = 6378137.0;
    final double latitudeRadians = center.latitude * math.pi / 180;
    final double deltaLatitude = radiusMeters / earthRadius * 180 / math.pi;
    final double deltaLongitude =
        radiusMeters /
        (earthRadius * math.cos(latitudeRadians)) *
        180 /
        math.pi;

    final List<VkLatLon> ring = <VkLatLon>[
      for (int i = 0; i < steps; i++)
        () {
          final double angle = 2 * math.pi * i / steps;
          return VkLatLon(
            center.latitude + deltaLatitude * math.sin(angle),
            center.longitude + deltaLongitude * math.cos(angle),
          );
        }(),
    ];
    return polygon(ring, properties: properties);
  }
}
