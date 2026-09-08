import 'package:meta/meta.dart';

/// Отступы в логических пикселях: от краёв карты к её видимой части.
///
/// Используются и для отступов камеры, и для положения логотипа VK.
@immutable
class VkEdgeInsets {
  /// Создаёт отступы.
  const VkEdgeInsets({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  /// Одинаковые отступы со всех сторон.
  const VkEdgeInsets.all(double value)
    : left = value,
      top = value,
      right = value,
      bottom = value;

  /// Нулевые отступы.
  static const VkEdgeInsets zero = VkEdgeInsets();

  /// Отступ слева.
  final double left;

  /// Отступ сверху.
  final double top;

  /// Отступ справа.
  final double right;

  /// Отступ снизу.
  final double bottom;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkEdgeInsets &&
          other.left == left &&
          other.top == top &&
          other.right == right &&
          other.bottom == bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() => 'VkEdgeInsets($left, $top, $right, $bottom)';
}
