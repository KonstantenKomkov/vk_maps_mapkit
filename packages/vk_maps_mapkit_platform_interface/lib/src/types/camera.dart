import 'package:meta/meta.dart';

import 'edge_insets.dart';
import 'lat_lon.dart';

/// Положение камеры карты.
@immutable
class VkCameraPosition {
  /// Создаёт положение камеры.
  const VkCameraPosition({
    required this.target,
    this.zoom = 10,
    this.bearing = 0,
    this.pitch = 0,
  });

  /// Точка, на которую смотрит камера.
  final VkLatLon target;

  /// Уровень масштабирования.
  final double zoom;

  /// Поворот в градусах по часовой стрелке от направления на север.
  final double bearing;

  /// Наклон камеры в градусах.
  final double pitch;

  /// Копия с заменёнными полями.
  VkCameraPosition copyWith({
    VkLatLon? target,
    double? zoom,
    double? bearing,
    double? pitch,
  }) => VkCameraPosition(
    target: target ?? this.target,
    zoom: zoom ?? this.zoom,
    bearing: bearing ?? this.bearing,
    pitch: pitch ?? this.pitch,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkCameraPosition &&
          other.target == target &&
          other.zoom == zoom &&
          other.bearing == bearing &&
          other.pitch == pitch;

  @override
  int get hashCode => Object.hash(target, zoom, bearing, pitch);

  @override
  String toString() =>
      'VkCameraPosition(target: $target, zoom: $zoom, bearing: $bearing, '
      'pitch: $pitch)';
}

/// Частичное изменение камеры: задаются только те поля, которые нужно менять.
///
/// Повторяет `MapCameraOptions` нативного SDK, где все поля необязательные.
@immutable
class VkCameraOptions {
  /// Создаёт набор изменений камеры.
  const VkCameraOptions({this.zoom, this.bearing, this.pitch, this.padding});

  /// Новый уровень масштабирования.
  final double? zoom;

  /// Новый поворот в градусах.
  final double? bearing;

  /// Новый наклон в градусах.
  final double? pitch;

  /// Новые отступы камеры.
  final VkEdgeInsets? padding;

  /// Нет ли в наборе ни одного изменения.
  bool get isEmpty =>
      zoom == null && bearing == null && pitch == null && padding == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkCameraOptions &&
          other.zoom == zoom &&
          other.bearing == bearing &&
          other.pitch == pitch &&
          other.padding == padding;

  @override
  int get hashCode => Object.hash(zoom, bearing, pitch, padding);

  @override
  String toString() =>
      'VkCameraOptions(zoom: $zoom, bearing: $bearing, pitch: $pitch, '
      'padding: $padding)';
}

/// Кривая ускорения анимации камеры.
///
/// Значения повторяют `MapAnimationEasing` нативного SDK.
enum VkAnimationEasing {
  /// Равномерное движение.
  linear,

  /// Плавный старт.
  easeIn,

  /// Плавное торможение.
  easeOut,

  /// Плавные старт и торможение.
  easeInOut,
}

/// Как трактовать заданную длительность анимации.
enum VkAnimationDurationMode {
  /// Ровно указанная длительность.
  exact,

  /// Не дольше указанной длительности: короткие перемещения пройдут быстрее.
  atMost,
}

/// Параметры анимации перемещения камеры.
@immutable
class VkAnimationOptions {
  /// Создаёт параметры анимации.
  const VkAnimationOptions({
    required this.duration,
    this.easing = VkAnimationEasing.linear,
    this.durationMode = VkAnimationDurationMode.exact,
  });

  /// Мгновенное перемещение без анимации.
  static const VkAnimationOptions none = VkAnimationOptions(
    duration: Duration.zero,
  );

  /// Длительность анимации.
  final Duration duration;

  /// Кривая ускорения.
  final VkAnimationEasing easing;

  /// Трактовка длительности.
  final VkAnimationDurationMode durationMode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkAnimationOptions &&
          other.duration == duration &&
          other.easing == easing &&
          other.durationMode == durationMode;

  @override
  int get hashCode => Object.hash(duration, easing, durationMode);

  @override
  String toString() =>
      'VkAnimationOptions(duration: $duration, easing: $easing, '
      'durationMode: $durationMode)';
}

/// Чем закончилось перемещение камеры.
enum VkCameraAnimationResult {
  /// Камера дошла до заданного положения.
  finished,

  /// Анимация прервана: новым перемещением или жестом пользователя.
  cancelled,
}
