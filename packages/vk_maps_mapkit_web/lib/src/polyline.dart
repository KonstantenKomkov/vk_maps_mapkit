import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';

/// Декодер закодированной ломаной маршрута.
///
/// На Android и iOS ломаную разбирает нативный SDK, на web такого метода
/// нет — источник принимает только GeoJSON, поэтому строка разбирается
/// здесь. Тот же алгоритм лежит в `vk_maps_api` (`VkPolyline`); связать
/// пакеты общей зависимостью нельзя: REST-клиент не зависит от Flutter, а
/// платформенный пакет не должен тянуть REST-клиент.
abstract final class VkWebPolyline {
  /// Точность по умолчанию: шесть знаков после запятой.
  static const double defaultPrecision = 1e6;

  /// Предел множителя групп: числа больше этого в координатах не бывают.
  ///
  /// Координата с точностью `1e6` укладывается в шесть групп по пять бит;
  /// предел взят с запасом и защищает от зацикливания на битой строке.
  static const int _maxMultiplier = 35184372088832; // 2^45

  /// Декодирует строку [encoded] в список точек.
  static List<VkLatLon> decode(
    String encoded, {
    double precision = defaultPrecision,
  }) {
    final List<VkLatLon> points = <VkLatLon>[];
    int index = 0;
    int lat = 0;
    int lon = 0;

    while (index < encoded.length) {
      lat += _decodeValue(encoded, index, (int next) => index = next);
      lon += _decodeValue(encoded, index, (int next) => index = next);
      points.add(VkLatLon(lat / precision, lon / precision));
    }
    return points;
  }

  /// Ломаная [encoded] в виде GeoJSON-объекта `LineString`.
  static String toGeoJson(
    String encoded, {
    double precision = defaultPrecision,
  }) => VkGeoJson.lineString(decode(encoded, precision: precision));

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
    // уезжает к полюсу. Ошибка не видна ни компилятору, ни тестам на VM.
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
