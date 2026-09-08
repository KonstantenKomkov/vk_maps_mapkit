import 'package:meta/meta.dart';

import '../types/camera.dart';
import '../types/lat_lon.dart';
import '../types/map_mode.dart';
import '../types/marker.dart';
import '../types/screen_point.dart';

/// Почему двигалась камера.
///
/// Повторяет `MapEvent.CameraMovingReason` нативного SDK.
enum VkCameraMovingReason {
  /// Жест пользователя.
  gesture,

  /// Программное перемещение из кода приложения.
  api,

  /// Следование за индикатором пользователя.
  followMode,

  /// Причина неизвестна или не сообщена платформой.
  unknown,
}

/// Фаза перемещения камеры.
///
/// Повторяет `MapEvent.CameraMovingPhase` нативного SDK.
enum VkCameraMovingPhase {
  /// Перемещение началось.
  started,

  /// Перемещение продолжается.
  moving,

  /// Одна из анимаций завершилась.
  singleCompleted,

  /// Все анимации завершились.
  allCompleted,

  /// Перемещение прервано.
  cancelled,
}

/// Событие карты.
///
/// События приходят одним потоком; конкретный тип разбирается сопоставлением
/// с образцом (`switch`), поэтому иерархия закрытая.
@immutable
sealed class VkMapEvent {
  /// Базовый конструктор.
  const VkMapEvent();
}

/// Карта впервые отрисована на экране.
@immutable
final class VkMapShownEvent extends VkMapEvent {
  /// Создаёт событие.
  const VkMapShownEvent();

  @override
  String toString() => 'VkMapShownEvent()';
}

/// Касание карты.
@immutable
final class VkMapTapEvent extends VkMapEvent {
  /// Создаёт событие касания.
  const VkMapTapEvent({
    required this.position,
    required this.screenPoint,
    this.isLongTap = false,
  });

  /// Координата точки касания.
  final VkLatLon position;

  /// Точка касания на экране.
  final VkScreenPoint screenPoint;

  /// Было ли касание долгим.
  final bool isLongTap;

  @override
  String toString() => 'VkMapTapEvent($position, longTap: $isLongTap)';
}

/// Касание маркера.
@immutable
final class VkMarkerTapEvent extends VkMapEvent {
  /// Создаёт событие касания маркера.
  const VkMarkerTapEvent({required this.markerId, required this.position});

  /// Идентификатор маркера.
  final VkMarkerId markerId;

  /// Координата маркера.
  final VkLatLon position;

  @override
  String toString() => 'VkMarkerTapEvent(${markerId.value}, $position)';
}

/// Камера сменила положение.
@immutable
final class VkCameraMoveEvent extends VkMapEvent {
  /// Создаёт событие перемещения камеры.
  const VkCameraMoveEvent({
    required this.position,
    required this.reason,
    required this.phase,
  });

  /// Новое положение камеры.
  final VkCameraPosition position;

  /// Почему камера двигалась.
  final VkCameraMovingReason reason;

  /// В какой фазе перемещение.
  final VkCameraMovingPhase phase;

  @override
  String toString() =>
      'VkCameraMoveEvent($position, reason: ${reason.name}, '
      'phase: ${phase.name})';
}

/// Стиль карты применён.
@immutable
final class VkStyleAppliedEvent extends VkMapEvent {
  /// Создаёт событие применения стиля.
  const VkStyleAppliedEvent();

  @override
  String toString() => 'VkStyleAppliedEvent()';
}

/// Режим следования изменился.
@immutable
final class VkMapModeChangedEvent extends VkMapEvent {
  /// Создаёт событие смены режима.
  const VkMapModeChangedEvent(this.mode);

  /// Новый режим следования.
  final VkMapMode mode;

  @override
  String toString() => 'VkMapModeChangedEvent(${mode.name})';
}

/// Ошибка, о которой сообщил нативный SDK.
@immutable
final class VkMapErrorEvent extends VkMapEvent {
  /// Создаёт событие ошибки.
  const VkMapErrorEvent({required this.code, required this.message});

  /// Код ошибки платформы.
  final String code;

  /// Сообщение платформы.
  final String message;

  @override
  String toString() => 'VkMapErrorEvent($code: $message)';
}

/// Карте не хватает памяти: платформа просит освободить ресурсы.
@immutable
final class VkMapLowMemoryEvent extends VkMapEvent {
  /// Создаёт событие нехватки памяти.
  const VkMapLowMemoryEvent();

  @override
  String toString() => 'VkMapLowMemoryEvent()';
}
