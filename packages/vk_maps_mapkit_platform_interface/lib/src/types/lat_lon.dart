import 'package:meta/meta.dart';

/// Географическая точка: широта и долгота в градусах.
///
/// В Dart-API порядок всегда «широта, долгота». В REST-ответах VK Карт
/// координаты приходят в обратном порядке (`[lon, lat]`) — разворот спрятан
/// в парсерах `vk_maps_api` и наружу не протекает.
@immutable
class VkLatLon {
  /// Создаёт точку.
  ///
  /// Широта ограничивается диапазоном −90…90, долгота приводится к
  /// полуинтервалу −180…180: значения за пределами не считаются ошибкой,
  /// потому что приходят из жестов и вычислений камеры.
  VkLatLon(double latitude, double longitude)
    : latitude = latitude.clamp(-90.0, 90.0),
      longitude = _normalizeLongitude(longitude);

  /// Широта в градусах, −90…90.
  final double latitude;

  /// Долгота в градусах, −180…180.
  final double longitude;

  static double _normalizeLongitude(double value) {
    if (value >= -180.0 && value < 180.0) {
      return value;
    }
    final double wrapped = (value + 180.0) % 360.0;
    return (wrapped < 0 ? wrapped + 360.0 : wrapped) - 180.0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkLatLon &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'VkLatLon($latitude, $longitude)';
}
