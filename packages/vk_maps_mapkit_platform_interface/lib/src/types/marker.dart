import 'package:meta/meta.dart';

import 'lat_lon.dart';
import 'maps_object.dart';
import 'maps_object_updates.dart';

/// Точка картинки маркера, которой он «стоит» на координате.
///
/// Значения повторяют `MarkerImageAlignment` нативного SDK.
enum VkMarkerAlignment {
  /// Центр картинки.
  center,

  /// Середина верхнего края.
  top,

  /// Середина нижнего края.
  bottom,

  /// Середина левого края.
  left,

  /// Середина правого края.
  right,

  /// Левый верхний угол.
  topLeft,

  /// Правый верхний угол.
  topRight,

  /// Левый нижний угол.
  bottomLeft,

  /// Правый нижний угол.
  bottomRight,
}

/// Идентификатор маркера.
typedef VkMarkerId = VkMapsObjectId<VkMarker>;

/// Маркер на карте.
///
/// Картинка задаётся идентификатором изображения, добавленного в стиль
/// (`imageId`), — так устроен нативный SDK: маркер ссылается на изображение,
/// а не носит его в себе.
@immutable
class VkMarker extends VkMapsObject<VkMarker> {
  /// Создаёт маркер.
  const VkMarker({
    required this.markerId,
    required this.position,
    required this.imageId,
    this.alignment = VkMarkerAlignment.bottom,
    this.zIndex = 0,
    this.visible = true,
  });

  /// Идентификатор маркера, уникальный в пределах карты.
  final VkMarkerId markerId;

  /// Координата маркера.
  final VkLatLon position;

  /// Идентификатор изображения в стиле карты.
  final String imageId;

  /// Точка картинки, которой маркер стоит на координате.
  final VkMarkerAlignment alignment;

  /// Порядок отрисовки: маркер с большим значением рисуется поверх.
  final int zIndex;

  /// Видимость маркера.
  final bool visible;

  @override
  VkMarkerId get mapsId => markerId;

  /// Копия с заменёнными полями.
  VkMarker copyWith({
    VkLatLon? position,
    String? imageId,
    VkMarkerAlignment? alignment,
    int? zIndex,
    bool? visible,
  }) => VkMarker(
    markerId: markerId,
    position: position ?? this.position,
    imageId: imageId ?? this.imageId,
    alignment: alignment ?? this.alignment,
    zIndex: zIndex ?? this.zIndex,
    visible: visible ?? this.visible,
  );

  @override
  VkMarker clone() => copyWith();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkMarker &&
          other.markerId == markerId &&
          other.position == position &&
          other.imageId == imageId &&
          other.alignment == alignment &&
          other.zIndex == zIndex &&
          other.visible == visible;

  @override
  int get hashCode =>
      Object.hash(markerId, position, imageId, alignment, zIndex, visible);

  @override
  String toString() =>
      'VkMarker(${markerId.value}, $position, image: $imageId, '
      'alignment: ${alignment.name}, zIndex: $zIndex, visible: $visible)';
}

/// Разница между двумя наборами маркеров.
class VkMarkerUpdates extends VkMapsObjectUpdates<VkMarker> {
  /// Считает разницу между наборами маркеров.
  VkMarkerUpdates.from(super.previous, super.current)
    : super.from(objectName: 'marker');
}
