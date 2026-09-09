import 'models/geo_point.dart';

/// Декодер закодированной ломаной маршрута.
///
/// Сервисы VK Карт отдают геометрию маршрута строкой в формате Encoded
/// Polyline с точностью `1e6` (шесть знаков после запятой).
abstract final class VkPolyline {
  /// Точность по умолчанию: шесть знаков после запятой.
  static const double defaultPrecision = 1e6;

  /// Предел множителя групп: числа больше этого в координатах не бывают.
  ///
  /// Координата с точностью `1e6` укладывается в шесть групп по пять бит;
  /// предел взят с запасом и защищает от зацикливания на битой строке.
  static const int _maxMultiplier = 35184372088832; // 2^45

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
    int multiplier = 1;
    int result = 0;
    int byte;
    int index = start;

    // Арифметика здесь только сложение, умножение и целочисленное деление.
    // Побитовые операции (`<<`, `>>`, `~`) в браузере считаются на 32 битах
    // со своей трактовкой знака: на виртуальной машине такой декодер даёт
    // верные координаты, а в собранном для web приложении часть точек
    // уезжает к полюсу.
    do {
      if (index >= encoded.length) {
        throw FormatException('Строка ломаной обрывается', encoded, index);
      }
      byte = encoded.codeUnitAt(index++) - 63;
      result += (byte % 32) * multiplier;
      multiplier *= 32;
      if (multiplier > _maxMultiplier) {
        throw FormatException(
          'Слишком длинное число в ломаной',
          encoded,
          index,
        );
      }
    } while (byte >= 0x20);

    setIndex(index);
    // Обратное zigzag-кодирование: младший бит — знак.
    return result.isOdd ? -((result + 1) ~/ 2) : result ~/ 2;
  }
}
