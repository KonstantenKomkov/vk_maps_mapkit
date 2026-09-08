import 'package:flutter/foundation.dart' show objectRuntimeType;
import 'package:meta/meta.dart';

/// Идентификатор объекта карты.
///
/// Типизирован объектом, к которому относится, чтобы идентификатор маркера
/// нельзя было передать туда, где ждут идентификатор другого типа.
@immutable
class VkMapsObjectId<T> {
  /// Создаёт идентификатор.
  const VkMapsObjectId(this.value);

  /// Строковое значение идентификатора, уникальное в пределах одной карты.
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkMapsObjectId<T> && other.value == value;

  @override
  int get hashCode => Object.hash(T, value);

  @override
  String toString() => '${objectRuntimeType(this, 'VkMapsObjectId')}($value)';
}

/// Объект, который кладётся на карту декларативным набором: маркер, линия,
/// многоугольник.
@immutable
abstract class VkMapsObject<T> {
  /// Базовый конструктор.
  const VkMapsObject();

  /// Идентификатор объекта.
  VkMapsObjectId<T> get mapsId;

  /// Копия объекта: нужна, чтобы наборы можно было сравнивать по значению.
  VkMapsObject<T> clone();
}

/// Ключует набор объектов по идентификатору.
Map<VkMapsObjectId<T>, T> keyByMapsObjectId<T extends VkMapsObject<T>>(
  Iterable<T> objects,
) => <VkMapsObjectId<T>, T>{
  for (final T object in objects) object.mapsId: object,
};
