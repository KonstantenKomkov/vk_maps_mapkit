import 'package:flutter/foundation.dart' show objectRuntimeType, setEquals;
import 'package:meta/meta.dart';

import 'maps_object.dart';

/// Разница между двумя наборами объектов карты.
///
/// Виджет держит объекты декларативным набором, а в натив уходит только
/// дельта: что добавить, что изменить и что удалить. Без этого каждая
/// перерисовка виджета перекладывала бы все объекты заново.
@immutable
class VkMapsObjectUpdates<T extends VkMapsObject<T>> {
  /// Считает разницу между [previous] и [current].
  VkMapsObjectUpdates.from(
    Set<T> previous,
    Set<T> current, {
    required this.objectName,
  }) {
    final Map<VkMapsObjectId<T>, T> previousObjects = keyByMapsObjectId(
      previous,
    );
    final Map<VkMapsObjectId<T>, T> currentObjects = keyByMapsObjectId(current);

    final Set<VkMapsObjectId<T>> previousIds = previousObjects.keys.toSet();
    final Set<VkMapsObjectId<T>> currentIds = currentObjects.keys.toSet();

    objectIdsToRemove = previousIds.difference(currentIds);
    objectsToAdd = currentIds
        .difference(previousIds)
        .map((VkMapsObjectId<T> id) => currentObjects[id]!)
        .toSet();
    objectsToChange = currentIds
        .intersection(previousIds)
        .map((VkMapsObjectId<T> id) => currentObjects[id]!)
        .where((T object) => object != previousObjects[object.mapsId])
        .toSet();
  }

  /// Имя типа объектов — попадает в сообщения об ошибках и в `toString`.
  final String objectName;

  /// Объекты, которых не было раньше.
  late final Set<T> objectsToAdd;

  /// Объекты, которые были и изменились.
  late final Set<T> objectsToChange;

  /// Идентификаторы объектов, которых больше нет.
  late final Set<VkMapsObjectId<T>> objectIdsToRemove;

  /// Пустая ли дельта: если да, вызывать натив не нужно.
  bool get isEmpty =>
      objectsToAdd.isEmpty &&
      objectsToChange.isEmpty &&
      objectIdsToRemove.isEmpty;

  /// Есть ли в дельте хоть одно изменение.
  bool get isNotEmpty => !isEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is VkMapsObjectUpdates<T> &&
        other.objectName == objectName &&
        setEquals(other.objectsToAdd, objectsToAdd) &&
        setEquals(other.objectsToChange, objectsToChange) &&
        setEquals(other.objectIdsToRemove, objectIdsToRemove);
  }

  @override
  int get hashCode => Object.hash(
    objectName,
    Object.hashAllUnordered(objectsToAdd),
    Object.hashAllUnordered(objectsToChange),
    Object.hashAllUnordered(objectIdsToRemove),
  );

  @override
  String toString() =>
      '${objectRuntimeType(this, 'VkMapsObjectUpdates')}($objectName, '
      'добавить: ${objectsToAdd.length}, изменить: ${objectsToChange.length}, '
      'удалить: ${objectIdsToRemove.length})';
}
