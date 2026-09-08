import 'models/geo_point.dart';

/// Декодер закодированной ломаной маршрута.
///
/// Сервисы VK Карт отдают геометрию маршрута строкой в формате Encoded
/// Polyline с точностью `1e6` (шесть знаков после запятой).
abstract final class VkPolyline {
  /// Точность по умолчанию: шесть знаков после запятой.
  static const double defaultPrecision = 1e6;

  /// Декодирует строку [encoded] в список точек.
  ///
  /// Порядок в результате — «широта, долгота», как во всём Dart-API, хотя
  /// примеры в документации VK Карт для разных языков расходятся в порядке.
  static List<VkGeoPoint> decode(
    String encoded, {
    double precision = defaultPrecision,
  }) {
    final List<VkGeoPoint> points = <VkGeoPoint>[];
    int index = 0;
    int lat = 0;
    int lon = 0;

    while (index < encoded.length) {
      lat += _decodeValue(encoded, index, (int next) => index = next);
      lon += _decodeValue(encoded, index, (int next) => index = next);
      points.add(VkGeoPoint(lat / precision, lon / precision));
    }
    return points;
  }

  static int _decodeValue(
    String encoded,
    int start,
    void Function(int next) setIndex,
  ) {
    int shift = 0;
    int result = 0;
    int byte;
    int index = start;

    do {
      if (index >= encoded.length) {
        throw FormatException('Строка ломаной обрывается', encoded, index);
      }
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);

    setIndex(index);
    return (result & 1) != 0 ? ~(result >> 1) : result >> 1;
  }
}
