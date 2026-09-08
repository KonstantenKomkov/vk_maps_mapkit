import 'package:meta/meta.dart';

/// Географическая точка в ответах REST-сервисов VK Карт.
///
/// В Dart-API порядок всегда «широта, долгота». В самих ответах координаты
/// приходят в поле `pin` в обратном порядке (`[lon, lat]`) — разворот делает
/// [VkGeoPoint.fromPin], наружу он не протекает.
@immutable
class VkGeoPoint {
  /// Создаёт точку из широты и долготы.
  const VkGeoPoint(this.latitude, this.longitude);

  /// Точка из пары `[lon, lat]`, как её отдают сервисы VK Карт.
  factory VkGeoPoint.fromPin(List<dynamic> pin) {
    if (pin.length < 2) {
      throw ArgumentError.value(pin, 'pin', 'Ожидалась пара [lon, lat]');
    }
    return VkGeoPoint((pin[1] as num).toDouble(), (pin[0] as num).toDouble());
  }

  /// Точка из объекта `{"lat": …, "lon": …}`, как их принимают маршруты.
  factory VkGeoPoint.fromJson(Map<String, dynamic> json) => VkGeoPoint(
    (json['lat'] as num).toDouble(),
    (json['lon'] as num).toDouble(),
  );

  /// Широта в градусах.
  final double latitude;

  /// Долгота в градусах.
  final double longitude;

  /// Представление `{"lat": …, "lon": …}` для тела запроса.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'lat': latitude,
    'lon': longitude,
  };

  /// Строка `lat,lon` для параметров запроса `location` и `q`.
  String toQueryValue() => '$latitude,$longitude';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkGeoPoint &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'VkGeoPoint($latitude, $longitude)';
}

/// Прямоугольная область в ответах сервисов.
@immutable
class VkBoundingBox {
  /// Создаёт область.
  const VkBoundingBox({required this.southwest, required this.northeast});

  /// Область из массива `[minLon, minLat, maxLon, maxLat]`.
  factory VkBoundingBox.fromBbox(List<dynamic> bbox) {
    if (bbox.length < 4) {
      throw ArgumentError.value(
        bbox,
        'bbox',
        'Ожидался массив [minLon, minLat, maxLon, maxLat]',
      );
    }
    return VkBoundingBox(
      southwest: VkGeoPoint(
        (bbox[1] as num).toDouble(),
        (bbox[0] as num).toDouble(),
      ),
      northeast: VkGeoPoint(
        (bbox[3] as num).toDouble(),
        (bbox[2] as num).toDouble(),
      ),
    );
  }

  /// Юго-западный угол.
  final VkGeoPoint southwest;

  /// Северо-восточный угол.
  final VkGeoPoint northeast;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkBoundingBox &&
          other.southwest == southwest &&
          other.northeast == northeast;

  @override
  int get hashCode => Object.hash(southwest, northeast);

  @override
  String toString() => 'VkBoundingBox($southwest, $northeast)';
}
