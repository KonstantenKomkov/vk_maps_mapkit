import 'dart:convert';

import 'package:meta/meta.dart';

/// Слой стиля карты.
///
/// Стили VK Карт — это Mapbox Style Spec, поэтому слой описывается тем же
/// JSON. Собственной модели выражений у плагина нет намеренно: спецификация
/// большая и живая, а её пересказ в Dart-типах устаревал бы быстрее, чем
/// приносил пользу. `paint` и `layout` передаются словарями.
@immutable
class VkStyleLayer {
  /// Создаёт слой произвольного типа.
  const VkStyleLayer({
    required this.id,
    required this.type,
    this.sourceId,
    this.sourceLayer,
    this.paint = const <String, Object?>{},
    this.layout = const <String, Object?>{},
    this.filter,
    this.minZoom,
    this.maxZoom,
  });

  /// Линия: маршрут, граница, трек.
  const VkStyleLayer.line({
    required String id,
    required String sourceId,
    Map<String, Object?> paint = const <String, Object?>{},
    Map<String, Object?> layout = const <String, Object?>{},
    List<Object?>? filter,
    double? minZoom,
    double? maxZoom,
  }) : this(
         id: id,
         type: 'line',
         sourceId: sourceId,
         paint: paint,
         layout: layout,
         filter: filter,
         minZoom: minZoom,
         maxZoom: maxZoom,
       );

  /// Заливка: зона, полигон, область достижимости.
  const VkStyleLayer.fill({
    required String id,
    required String sourceId,
    Map<String, Object?> paint = const <String, Object?>{},
    Map<String, Object?> layout = const <String, Object?>{},
    List<Object?>? filter,
    double? minZoom,
    double? maxZoom,
  }) : this(
         id: id,
         type: 'fill',
         sourceId: sourceId,
         paint: paint,
         layout: layout,
         filter: filter,
         minZoom: minZoom,
         maxZoom: maxZoom,
       );

  /// Круги: точки, кластеры.
  const VkStyleLayer.circle({
    required String id,
    required String sourceId,
    Map<String, Object?> paint = const <String, Object?>{},
    Map<String, Object?> layout = const <String, Object?>{},
    List<Object?>? filter,
    double? minZoom,
    double? maxZoom,
  }) : this(
         id: id,
         type: 'circle',
         sourceId: sourceId,
         paint: paint,
         layout: layout,
         filter: filter,
         minZoom: minZoom,
         maxZoom: maxZoom,
       );

  /// Символы: иконки и подписи.
  const VkStyleLayer.symbol({
    required String id,
    required String sourceId,
    Map<String, Object?> paint = const <String, Object?>{},
    Map<String, Object?> layout = const <String, Object?>{},
    List<Object?>? filter,
    double? minZoom,
    double? maxZoom,
  }) : this(
         id: id,
         type: 'symbol',
         sourceId: sourceId,
         paint: paint,
         layout: layout,
         filter: filter,
         minZoom: minZoom,
         maxZoom: maxZoom,
       );

  /// Идентификатор слоя, уникальный в пределах стиля.
  final String id;

  /// Тип слоя по спецификации: `line`, `fill`, `circle`, `symbol` и другие.
  final String type;

  /// Идентификатор источника данных.
  final String? sourceId;

  /// Слой внутри векторного источника.
  final String? sourceLayer;

  /// Свойства отрисовки.
  final Map<String, Object?> paint;

  /// Свойства раскладки.
  final Map<String, Object?> layout;

  /// Фильтр объектов источника.
  final List<Object?>? filter;

  /// Минимальный зум, с которого слой виден.
  final double? minZoom;

  /// Максимальный зум, до которого слой виден.
  final double? maxZoom;

  /// Представление слоя по спецификации Mapbox Style.
  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'type': type,
    if (sourceId != null) 'source': sourceId,
    if (sourceLayer != null) 'source-layer': sourceLayer,
    if (paint.isNotEmpty) 'paint': paint,
    if (layout.isNotEmpty) 'layout': layout,
    if (filter != null) 'filter': filter,
    if (minZoom != null) 'minzoom': minZoom,
    if (maxZoom != null) 'maxzoom': maxZoom,
  };

  /// Слой строкой JSON — в этом виде его принимает нативный SDK.
  String toJsonString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkStyleLayer && other.toJsonString() == toJsonString();

  @override
  int get hashCode => toJsonString().hashCode;

  @override
  String toString() => 'VkStyleLayer($id, $type)';
}
