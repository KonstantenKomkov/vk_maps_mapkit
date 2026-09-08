import 'package:meta/meta.dart';

/// Точка на экране в логических пикселях относительно левого верхнего угла
/// карты.
@immutable
class VkScreenPoint {
  /// Создаёт экранную точку.
  const VkScreenPoint(this.x, this.y);

  /// Координата по горизонтали.
  final double x;

  /// Координата по вертикали.
  final double y;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkScreenPoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'VkScreenPoint($x, $y)';
}
