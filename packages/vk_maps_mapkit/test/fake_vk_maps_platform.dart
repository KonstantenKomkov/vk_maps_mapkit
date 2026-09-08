import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';

/// Подставная платформа: вместо нативной карты рисует пустой прямоугольник и
/// записывает все обращения фасада.
final class FakeVkMapsPlatform extends VkMapsPlatform {
  /// Создаёт подставную платформу.
  FakeVkMapsPlatform({this.viewIdToReturn = 1});

  /// Идентификатор, который получит созданная карта.
  final int viewIdToReturn;

  /// Записанные вызовы в порядке поступления.
  final List<String> calls = <String>[];

  /// Последняя применённая дельта настроек.
  VkMapConfiguration? lastConfiguration;

  /// Последняя применённая дельта маркеров.
  VkMarkerUpdates? lastMarkerUpdates;

  /// Начальные параметры последней созданной карты.
  VkMapInitialConfiguration? lastInitialConfiguration;

  final Map<int, StreamController<VkMapEvent>> _events =
      <int, StreamController<VkMapEvent>>{};

  /// Присылает событие в поток карты [viewId], как это сделал бы натив.
  void emit(int viewId, VkMapEvent event) {
    _events[viewId]?.add(event);
  }

  /// Закрывает все потоки: вызывается в `tearDown`.
  Future<void> close() async {
    for (final StreamController<VkMapEvent> controller in _events.values) {
      await controller.close();
    }
    _events.clear();
  }

  @override
  Widget buildView({
    required VkMapInitialConfiguration configuration,
    required void Function(int viewId) onPlatformViewCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers =
        const <Factory<OneSequenceGestureRecognizer>>{},
    PlatformViewHitTestBehavior hitTestBehavior =
        PlatformViewHitTestBehavior.opaque,
    TextDirection? layoutDirection,
  }) {
    lastInitialConfiguration = configuration;
    calls.add('buildView');
    return _FakePlatformView(
      viewId: viewIdToReturn,
      onPlatformViewCreated: onPlatformViewCreated,
    );
  }

  @override
  Future<void> initialize({
    required String apiKey,
    String? baseUrl,
    String? locale,
  }) async => calls.add('initialize($apiKey, $baseUrl, $locale)');

  @override
  Future<bool> isInitialized() async => true;

  @override
  Future<void> updateConfiguration(
    int viewId,
    VkMapConfiguration configuration,
  ) async {
    calls.add('updateConfiguration($viewId)');
    lastConfiguration = configuration;
  }

  @override
  Future<void> updateMarkers(int viewId, VkMarkerUpdates updates) async {
    calls.add(
      'updateMarkers($viewId, +${updates.objectsToAdd.length} '
      '~${updates.objectsToChange.length} -${updates.objectIdsToRemove.length})',
    );
    lastMarkerUpdates = updates;
  }

  @override
  Future<VkCameraAnimationResult> moveCamera(
    int viewId, {
    VkLatLon? target,
    VkCameraOptions? options,
    VkAnimationOptions? animation,
  }) async {
    calls.add('moveCamera($viewId, ${target?.latitude}, ${options?.zoom})');
    return VkCameraAnimationResult.finished;
  }

  @override
  Future<VkCameraAnimationResult> fitBounds(
    int viewId,
    VkLatLonBounds bounds, {
    VkEdgeInsets padding = VkEdgeInsets.zero,
    VkAnimationOptions? animation,
  }) async {
    calls.add('fitBounds($viewId)');
    return VkCameraAnimationResult.finished;
  }

  @override
  Future<VkCameraPosition> getCameraPosition(int viewId) async {
    calls.add('getCameraPosition($viewId)');
    return VkCameraPosition(target: VkLatLon(55.0, 37.0), zoom: 10);
  }

  @override
  Future<VkLatLonBounds> getVisibleBounds(int viewId) async => VkLatLonBounds(
    southwest: VkLatLon(55.0, 37.0),
    northeast: VkLatLon(56.0, 38.0),
  );

  @override
  Future<VkLatLon?> coordinateForScreenPoint(
    int viewId,
    VkScreenPoint point,
  ) async => VkLatLon(55.0, 37.0);

  @override
  Future<VkScreenPoint?> screenPointForCoordinate(
    int viewId,
    VkLatLon coordinate,
  ) async => const VkScreenPoint(1, 2);

  @override
  Future<VkMapMode> getMode(int viewId) async => VkMapMode.free;

  @override
  Future<void> setMode(int viewId, VkMapMode mode) async =>
      calls.add('setMode($viewId, ${mode.name})');

  @override
  Future<void> setUserLocation(
    int viewId, {
    VkLatLon? coordinates,
    double? bearing,
    double? accuracy,
    bool visible = true,
  }) async => calls.add('setUserLocation($viewId, visible: $visible)');

  @override
  Future<void> addStyleImage(
    int viewId,
    String imageId,
    Uint8List pngBytes, {
    double scale = 1.0,
  }) async => calls.add('addStyleImage($viewId, $imageId)');

  @override
  Future<void> removeStyleImage(int viewId, String imageId) async =>
      calls.add('removeStyleImage($viewId, $imageId)');

  @override
  Future<void> dispose(int viewId) async {
    calls.add('dispose($viewId)');
    await _events.remove(viewId)?.close();
  }

  @override
  Stream<VkMapEvent> events(int viewId) => _events
      .putIfAbsent(viewId, () => StreamController<VkMapEvent>.broadcast())
      .stream;
}

class _FakePlatformView extends StatefulWidget {
  const _FakePlatformView({
    required this.viewId,
    required this.onPlatformViewCreated,
  });

  final int viewId;
  final void Function(int viewId) onPlatformViewCreated;

  @override
  State<_FakePlatformView> createState() => _FakePlatformViewState();
}

class _FakePlatformViewState extends State<_FakePlatformView> {
  @override
  void initState() {
    super.initState();
    widget.onPlatformViewCreated(widget.viewId);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
