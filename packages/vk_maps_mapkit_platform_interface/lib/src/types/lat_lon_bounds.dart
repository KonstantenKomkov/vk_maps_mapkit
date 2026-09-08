import 'package:meta/meta.dart';

import 'lat_lon.dart';

/// Прямоугольная географическая область: юго-западный и северо-восточный углы.
@immutable
class VkLatLonBounds {
  /// Создаёт область.
  ///
  /// Широта [southwest] не должна быть больше широты [northeast]; по долготе
  /// область может пересекать 180-й меридиан, поэтому долготы не сверяются.
  VkLatLonBounds({required this.southwest, required this.northeast})
    : assert(
        southwest.latitude <= northeast.latitude,
        'Широта юго-западного угла больше северо-восточного',
      );

  /// Юго-западный угол области.
  final VkLatLon southwest;

  /// Северо-восточный угол области.
  final VkLatLon northeast;

  /// Пересекает ли область 180-й меридиан.
  bool get crossesAntimeridian => southwest.longitude > northeast.longitude;

  /// Содержит ли область точку [point].
  bool contains(VkLatLon point) {
    if (point.latitude < southwest.latitude ||
        point.latitude > northeast.latitude) {
      return false;
    }
    if (crossesAntimeridian) {
      return point.longitude >= southwest.longitude ||
          point.longitude <= northeast.longitude;
    }
    return point.longitude >= southwest.longitude &&
        point.longitude <= northeast.longitude;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkLatLonBounds &&
          other.southwest == southwest &&
          other.northeast == northeast;

  @override
  int get hashCode => Object.hash(southwest, northeast);

  @override
  String toString() => 'VkLatLonBounds($southwest, $northeast)';
}
