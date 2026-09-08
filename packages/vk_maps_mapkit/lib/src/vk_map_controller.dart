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
}
