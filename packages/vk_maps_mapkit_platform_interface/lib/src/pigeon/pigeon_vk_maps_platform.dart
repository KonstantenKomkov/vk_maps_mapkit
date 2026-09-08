import 'dart:async';
import 'dart:typed_data';

import '../../vk_maps_mapkit_platform_interface.dart';
import '../messages.g.dart';
import 'converters.dart';

/// Реализация контракта поверх сгенерированного Pigeon-моста.
///
/// Логика одинакова для Android и iOS, поэтому платформенные пакеты
/// наследуются от неё и переопределяют только построение нативного
/// представления.
base class PigeonVkMapsPlatform extends VkMapsPlatform
    implements VkMapsFlutterApi {
  /// Создаёт реализацию и подписывается на события из натива.
  PigeonVkMapsPlatform({
    VkMapsHostApi? hostApi,
    VkMapsInitializerApi? initializerApi,
    bool listenToEvents = true,
  }) : _host = hostApi ?? VkMapsHostApi(),
       _initializer = initializerApi ?? VkMapsInitializerApi() {
    if (listenToEvents) {
      VkMapsFlutterApi.setUp(this);
    }
  }

  final VkMapsHostApi _host;
  final VkMapsInitializerApi _initializer;
  final Map<int, StreamController<VkMapEvent>> _events =
      <int, StreamController<VkMapEvent>>{};

  StreamController<VkMapEvent> _controllerFor(int viewId) => _events
      .putIfAbsent(viewId, () => StreamController<VkMapEvent>.broadcast());

  /// Закрывает потоки событий всех карт.
  ///
  /// Нужен тестам и на случай выгрузки плагина: обычный путь — [dispose]
  /// для каждой карты.
  Future<void> closeAllEventStreams() async {
    final List<StreamController<VkMapEvent>> controllers = _events.values
        .toList();
    _events.clear();
    for (final StreamController<VkMapEvent> controller in controllers) {
      await controller.close();
    }
  }

  @override
  Future<void> initialize({
    required String apiKey,
    String? baseUrl,
    String? locale,
  }) => _initializer.setup(apiKey, baseUrl, locale);

  @override
  Future<bool> isInitialized() => _initializer.isInitialized();

  @override
  Future<void> updateConfiguration(
    int viewId,
    VkMapConfiguration configuration,
  ) {
    if (configuration.isEmpty) {
      return Future<void>.value();
    }
    return _host.updateConfiguration(viewId, configuration.toMessage());
  }

  @override
  Future<void> updateMarkers(int viewId, VkMarkerUpdates updates) {
    if (updates.isEmpty) {
      return Future<void>.value();
    }
    return _host.updateMarkers(viewId, updates.toMessage());
  }

  @override
  Future<VkCameraAnimationResult> moveCamera(
    int viewId, {
    VkLatLon? target,
    VkCameraOptions? options,
    VkAnimationOptions? animation,
  }) async => cameraResultFromMessage(
    await _host.moveCamera(
      viewId,
      target?.toMessage(),
      options?.toMessage(),
      animation?.toMessage(),
    ),
  );

  @override
  Future<VkCameraAnimationResult> fitBounds(
    int viewId,
    VkLatLonBounds bounds, {
    VkEdgeInsets padding = VkEdgeInsets.zero,
    VkAnimationOptions? animation,
  }) async => cameraResultFromMessage(
    await _host.fitBounds(
      viewId,
      PlatformLatLonBounds(
        southwest: bounds.southwest.toMessage(),
        northeast: bounds.northeast.toMessage(),
      ),
      padding.toMessage(),
      animation?.toMessage(),
    ),
  );

  @override
  Future<VkCameraPosition> getCameraPosition(int viewId) async =>
      cameraPositionFromMessage(await _host.getCameraPosition(viewId));

  @override
  Future<VkLatLonBounds> getVisibleBounds(int viewId) async =>
      boundsFromMessage(await _host.getVisibleBounds(viewId));

  @override
  Future<VkLatLon?> coordinateForScreenPoint(
    int viewId,
    VkScreenPoint point,
  ) async {
    final PlatformLatLon? result = await _host.coordinateForScreenPoint(
      viewId,
      point.toMessage(),
    );
    return result == null ? null : latLonFromMessage(result);
  }

  @override
  Future<VkScreenPoint?> screenPointForCoordinate(
    int viewId,
    VkLatLon coordinate,
  ) async {
    final PlatformScreenPoint? result = await _host.screenPointForCoordinate(
      viewId,
      coordinate.toMessage(),
    );
    return result == null ? null : screenPointFromMessage(result);
  }

  @override
  Future<VkMapMode> getMode(int viewId) async =>
      mapModeFromMessage(await _host.getMode(viewId));

  @override
  Future<void> setMode(int viewId, VkMapMode mode) =>
      _host.setMode(viewId, mapModeToMessage(mode));

  @override
  Future<void> setUserLocation(
    int viewId, {
    VkLatLon? coordinates,
    double? bearing,
    double? accuracy,
    bool visible = true,
  }) => _host.setUserLocation(
    viewId,
    coordinates?.toMessage(),
    bearing,
    accuracy,
    visible,
  );

  @override
  Future<void> addStyleImage(
    int viewId,
    String imageId,
    Uint8List pngBytes, {
    double scale = 1.0,
  }) => _host.addStyleImage(viewId, imageId, pngBytes, scale);

  @override
  Future<void> removeStyleImage(int viewId, String imageId) =>
      _host.removeStyleImage(viewId, imageId);

  @override
  Future<void> dispose(int viewId) async {
    await _host.dispose(viewId);
    await _events.remove(viewId)?.close();
  }

  @override
  Stream<VkMapEvent> events(int viewId) => _controllerFor(viewId).stream;

  @override
  void onEvent(int viewId, PlatformMapEvent event) {
    final VkMapEvent? converted = mapEventFromMessage(event);
    if (converted == null) {
      return;
    }
    if (!_controllerFor(viewId).isClosed) {
      _controllerFor(viewId).add(converted);
    }
  }
}
