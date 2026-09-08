import 'dart:typed_data';

import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';

/// Управление конкретной картой.
///
/// Приходит в `onMapCreated` и живёт, пока карта в дереве виджетов.
class VkMapController {
  /// Создаёт контроллер для карты [viewId].
  ///
  /// Создаётся виджетом [VkMap]; напрямую вызывать не нужно.
  VkMapController(this.viewId);

  /// Идентификатор нативного представления карты.
  final int viewId;

  VkMapsPlatform get _platform => VkMapsPlatform.instance;

  /// Поток событий этой карты.
  Stream<VkMapEvent> get events => _platform.events(viewId);

  /// Перемещает камеру с анимацией.
  ///
  /// [target] — новая точка центра, [options] — зум, поворот, наклон и
  /// отступы. Незаданные параметры остаются прежними.
  Future<VkCameraAnimationResult> animateCamera({
    VkLatLon? target,
    VkCameraOptions? options,
    VkAnimationOptions animation = const VkAnimationOptions(
      duration: Duration(milliseconds: 300),
    ),
  }) => _platform.moveCamera(
    viewId,
    target: target,
    options: options,
    animation: animation,
  );

  /// Мгновенно переносит камеру без анимации.
  Future<VkCameraAnimationResult> moveCamera({
    VkLatLon? target,
    VkCameraOptions? options,
  }) => _platform.moveCamera(viewId, target: target, options: options);

  /// Вписывает область в видимую часть карты.
  Future<VkCameraAnimationResult> fitBounds(
    VkLatLonBounds bounds, {
    VkEdgeInsets padding = VkEdgeInsets.zero,
    VkAnimationOptions? animation,
  }) => _platform.fitBounds(
    viewId,
    bounds,
    padding: padding,
    animation: animation,
  );

  /// Меняет уровень масштабирования на [delta] с анимацией.
  Future<VkCameraAnimationResult> zoomBy(
    double delta, {
    VkAnimationOptions animation = const VkAnimationOptions(
      duration: Duration(milliseconds: 200),
    ),
  }) async {
    final VkCameraPosition position = await getCameraPosition();
    return animateCamera(
      options: VkCameraOptions(zoom: position.zoom + delta),
      animation: animation,
    );
  }

  /// Текущее положение камеры.
  Future<VkCameraPosition> getCameraPosition() =>
      _platform.getCameraPosition(viewId);

  /// Границы видимой области карты.
  Future<VkLatLonBounds> getVisibleBounds() =>
      _platform.getVisibleBounds(viewId);

  /// Координата по точке на экране, если точка попадает в карту.
  Future<VkLatLon?> coordinateForScreenPoint(VkScreenPoint point) =>
      _platform.coordinateForScreenPoint(viewId, point);

  /// Точка на экране по координате, если она видна.
  Future<VkScreenPoint?> screenPointForCoordinate(VkLatLon coordinate) =>
      _platform.screenPointForCoordinate(viewId, coordinate);

  /// Текущий режим следования за индикатором пользователя.
  Future<VkMapMode> getMode() => _platform.getMode(viewId);

  /// Устанавливает режим следования.
  Future<void> setMode(VkMapMode mode) => _platform.setMode(viewId, mode);

  /// Задаёт положение индикатора пользователя.
  ///
  /// Плагин не запрашивает геолокацию сам: координаты передаёт приложение,
  /// которое само решает вопрос с разрешениями.
  Future<void> setUserLocation({
    VkLatLon? coordinates,
    double? bearing,
    double? accuracy,
    bool visible = true,
  }) => _platform.setUserLocation(
    viewId,
    coordinates: coordinates,
    bearing: bearing,
    accuracy: accuracy,
    visible: visible,
  );

  /// Добавляет изображение в стиль карты.
  ///
  /// На него ссылаются маркеры по [imageId]; [scale] — во сколько раз
  /// изображение крупнее логического пикселя.
  Future<void> addStyleImage(
    String imageId,
    Uint8List pngBytes, {
    double scale = 1.0,
  }) => _platform.addStyleImage(viewId, imageId, pngBytes, scale: scale);

  /// Убирает изображение из стиля карты.
  Future<void> removeStyleImage(String imageId) =>
      _platform.removeStyleImage(viewId, imageId);

  /// Добавляет в стиль источник данных GeoJSON.
  Future<void> addGeoJsonSource(String sourceId, String geoJson) =>
      _platform.addGeoJsonSource(viewId, sourceId, geoJson);

  /// Заменяет данные источника GeoJSON, не пересоздавая его.
  Future<void> setGeoJsonSourceData(String sourceId, String geoJson) =>
      _platform.setGeoJsonSourceData(viewId, sourceId, geoJson);

  /// Добавляет источник из закодированной ломаной маршрута.
  ///
  /// Строку отдаёт `vk_maps_api` в поле `shape` участка маршрута.
  Future<void> addEncodedPolylineSource(String sourceId, String polyline) =>
      _platform.addEncodedPolylineSource(viewId, sourceId, polyline);

  /// Убирает источник из стиля.
  Future<void> removeSource(String sourceId) =>
      _platform.removeSource(viewId, sourceId);

  /// Добавляет слой стиля.
  ///
  /// [beforeLayerId] вставляет слой под уже существующий: так линия
  /// маршрута кладётся под подписи, а не поверх них.
  Future<void> addLayer(VkStyleLayer layer, {String? beforeLayerId}) =>
      _platform.addLayer(viewId, layer, beforeLayerId: beforeLayerId);

  /// Убирает слой из стиля.
  Future<void> removeLayer(String layerId) =>
      _platform.removeLayer(viewId, layerId);

  /// Показывает или скрывает слой.
  Future<void> setLayerVisibility(String layerId, {required bool visible}) =>
      _platform.setLayerVisibility(viewId, layerId, visible);

  /// Рисует маршрут по закодированной ломаной.
  ///
  /// Создаёт источник и линию одним вызовом; повторный вызов с тем же [id]
  /// заменяет геометрию, не пересоздавая слой.
  Future<void> drawRoute(
    String encodedPolyline, {
    String id = 'route',
    String color = '#0077FF',
    double width = 6,
    double opacity = 1,
    String? beforeLayerId,
  }) async {
    final String sourceId = '$id-source';
    if (_drawnIds.add(id)) {
      await addEncodedPolylineSource(sourceId, encodedPolyline);
      await addLayer(
        VkStyleLayer.line(
          id: id,
          sourceId: sourceId,
          paint: <String, Object?>{
            'line-color': color,
            'line-width': width,
            'line-opacity': opacity,
          },
          layout: <String, Object?>{'line-cap': 'round', 'line-join': 'round'},
        ),
        beforeLayerId: beforeLayerId,
      );
    } else {
      await _platform.addEncodedPolylineSource(
        viewId,
        sourceId,
        encodedPolyline,
      );
    }
  }

  /// Рисует многоугольник по списку точек.
  Future<void> drawPolygon(
    List<VkLatLon> points, {
    String id = 'polygon',
    String fillColor = '#0077FF',
    double fillOpacity = 0.2,
    String? outlineColor,
    String? beforeLayerId,
  }) => _drawGeoJson(
    id: id,
    geoJson: VkGeoJson.polygon(points),
    layer: VkStyleLayer.fill(
      id: id,
      sourceId: '$id-source',
      paint: <String, Object?>{
        'fill-color': fillColor,
        'fill-opacity': fillOpacity,
        'fill-outline-color': ?outlineColor,
      },
    ),
    beforeLayerId: beforeLayerId,
  );

  /// Рисует круг заданного радиуса в метрах.
  ///
  /// Круг приближается многоугольником на стороне Dart: нативного круга нет
  /// ни на одной платформе, а так результат одинаков.
  Future<void> drawCircle(
    VkLatLon center,
    double radiusMeters, {
    String id = 'circle',
    int steps = 64,
    String fillColor = '#0077FF',
    double fillOpacity = 0.2,
    String? beforeLayerId,
  }) => _drawGeoJson(
    id: id,
    geoJson: VkGeoJson.circle(center, radiusMeters, steps: steps),
    layer: VkStyleLayer.fill(
      id: id,
      sourceId: '$id-source',
      paint: <String, Object?>{
        'fill-color': fillColor,
        'fill-opacity': fillOpacity,
      },
    ),
    beforeLayerId: beforeLayerId,
  );

  /// Убирает нарисованный рецептом объект вместе с его источником.
  Future<void> removeDrawing(String id) async {
    if (!_drawnIds.remove(id)) {
      return;
    }
    await removeLayer(id);
    await removeSource('$id-source');
  }

  Future<void> _drawGeoJson({
    required String id,
    required String geoJson,
    required VkStyleLayer layer,
    String? beforeLayerId,
  }) async {
    final String sourceId = '$id-source';
    if (_drawnIds.add(id)) {
      await addGeoJsonSource(sourceId, geoJson);
      await addLayer(layer, beforeLayerId: beforeLayerId);
    } else {
      await setGeoJsonSourceData(sourceId, geoJson);
    }
  }

  final Set<String> _drawnIds = <String>{};
}
