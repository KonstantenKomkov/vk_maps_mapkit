import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vk_maps_mapkit_platform_interface/src/messages.g.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';

/// Хост-API, который ничего не отправляет, а записывает вызовы.
class _RecordingHostApi implements VkMapsHostApi {
  // Имена полей заданы генератором Pigeon, отсюда стиль.
  @override
  // ignore: non_constant_identifier_names
  final BinaryMessenger? pigeonVar_binaryMessenger = null;

  @override
  // ignore: non_constant_identifier_names
  final String pigeonVar_messageChannelSuffix = '';

  final List<String> calls = <String>[];
  PlatformMarkerUpdates? lastMarkerUpdates;
  PlatformMapConfiguration? lastConfiguration;

  @override
  Future<void> updateConfiguration(
    int viewId,
    PlatformMapConfiguration configuration,
  ) async {
    calls.add('updateConfiguration($viewId)');
    lastConfiguration = configuration;
  }

  @override
  Future<void> updateMarkers(int viewId, PlatformMarkerUpdates updates) async {
    calls.add('updateMarkers($viewId)');
    lastMarkerUpdates = updates;
  }

  @override
  Future<PlatformCameraAnimationResult> moveCamera(
    int viewId,
    PlatformLatLon? target,
    PlatformCameraOptions? options,
    PlatformAnimationOptions? animation,
  ) async {
    calls.add(
      'moveCamera($viewId, ${target?.latitude}, ${options?.zoom}, '
      '${animation?.durationMillis})',
    );
    return PlatformCameraAnimationResult.finished;
  }

  @override
  Future<PlatformCameraAnimationResult> fitBounds(
    int viewId,
    PlatformLatLonBounds bounds,
    PlatformEdgeInsets padding,
    PlatformAnimationOptions? animation,
  ) async {
    calls.add('fitBounds($viewId)');
    return PlatformCameraAnimationResult.cancelled;
  }

  @override
  Future<PlatformCameraPosition> getCameraPosition(int viewId) async {
    calls.add('getCameraPosition($viewId)');
    return PlatformCameraPosition(
      target: PlatformLatLon(latitude: 55.0, longitude: 37.0),
      zoom: 12,
      bearing: 0,
      pitch: 0,
    );
  }

  @override
  Future<PlatformLatLonBounds> getVisibleBounds(int viewId) async =>
      PlatformLatLonBounds(
        southwest: PlatformLatLon(latitude: 55.0, longitude: 37.0),
        northeast: PlatformLatLon(latitude: 56.0, longitude: 38.0),
      );

  @override
  Future<PlatformLatLon?> coordinateForScreenPoint(
    int viewId,
    PlatformScreenPoint point,
  ) async => null;

  @override
  Future<PlatformScreenPoint?> screenPointForCoordinate(
    int viewId,
    PlatformLatLon coordinate,
  ) async => PlatformScreenPoint(x: 1, y: 2);

  @override
  Future<PlatformMapMode> getMode(int viewId) async => PlatformMapMode.free;

  @override
  Future<void> setMode(int viewId, PlatformMapMode mode) async {
    calls.add('setMode($viewId, ${mode.name})');
  }

  @override
  Future<void> setUserLocation(
    int viewId,
    PlatformLatLon? coordinates,
    double? bearing,
    double? accuracy,
    bool visible,
  ) async {
    calls.add('setUserLocation($viewId, visible: $visible)');
  }

  @override
  Future<void> addStyleImage(
    int viewId,
    String imageId,
    Uint8List pngBytes,
    double scale,
  ) async {
    calls.add('addStyleImage($viewId, $imageId, ${pngBytes.length}, $scale)');
  }

  @override
  Future<void> removeStyleImage(int viewId, String imageId) async {
    calls.add('removeStyleImage($viewId, $imageId)');
  }

  @override
  Future<void> dispose(int viewId) async {
    calls.add('dispose($viewId)');
  }
}

class _RecordingInitializerApi implements VkMapsInitializerApi {
  // Имена полей заданы генератором Pigeon, отсюда стиль.
  @override
  // ignore: non_constant_identifier_names
  final BinaryMessenger? pigeonVar_binaryMessenger = null;

  @override
  // ignore: non_constant_identifier_names
  final String pigeonVar_messageChannelSuffix = '';

  final List<String> calls = <String>[];

  @override
  Future<bool> setup(String apiKey, String? baseUrl, String? locale) async {
    calls.add('setup($apiKey, $baseUrl, $locale)');
    return true;
  }

  @override
  Future<bool> isInitialized() async => calls.isNotEmpty;
}

VkMarker _marker(String id, {double lat = 55.0}) => VkMarker(
  markerId: VkMarkerId(id),
  position: VkLatLon(lat, 37.0),
  imageId: 'pin',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingHostApi host;
  late _RecordingInitializerApi initializer;
  late PigeonVkMapsPlatform platform;

  setUp(() {
    host = _RecordingHostApi();
    initializer = _RecordingInitializerApi();
    platform = PigeonVkMapsPlatform(
      hostApi: host,
      initializerApi: initializer,
      listenToEvents: false,
    );
  });

  tearDown(() async {
    await platform.closeAllEventStreams();
  });

  group('пустые дельты', () {
    test('пустая конфигурация не уходит в натив', () async {
      await platform.updateConfiguration(1, const VkMapConfiguration());
      expect(host.calls, isEmpty);
    });

    test('пустая дельта маркеров не уходит в натив', () async {
      await platform.updateMarkers(
        1,
        VkMarkerUpdates.from(
          <VkMarker>{_marker('a')},
          <VkMarker>{_marker('a')},
        ),
      );
      expect(host.calls, isEmpty);
    });

    test('непустая дельта уходит один раз', () async {
      await platform.updateMarkers(
        7,
        VkMarkerUpdates.from(<VkMarker>{}, <VkMarker>{_marker('a')}),
      );
      expect(host.calls, <String>['updateMarkers(7)']);
      expect(host.lastMarkerUpdates!.toAdd.single.markerId, 'a');
      expect(host.lastMarkerUpdates!.idsToRemove, isEmpty);
    });
  });

  group('камера', () {
    test('moveCamera передаёт цель, опции и анимацию', () async {
      final VkCameraAnimationResult result = await platform.moveCamera(
        3,
        target: VkLatLon(55.5, 37.5),
        options: const VkCameraOptions(zoom: 14),
        animation: const VkAnimationOptions(
          duration: Duration(milliseconds: 300),
        ),
      );
      expect(result, VkCameraAnimationResult.finished);
      expect(host.calls.single, 'moveCamera(3, 55.5, 14.0, 300)');
    });

    test('прерванная анимация доходит как cancelled', () async {
      final VkCameraAnimationResult result = await platform.fitBounds(
        1,
        VkLatLonBounds(
          southwest: VkLatLon(55, 37),
          northeast: VkLatLon(56, 38),
        ),
      );
      expect(result, VkCameraAnimationResult.cancelled);
    });

    test('положение камеры разворачивается в модель', () async {
      final VkCameraPosition position = await platform.getCameraPosition(1);
      expect(position.target, VkLatLon(55.0, 37.0));
      expect(position.zoom, 12);
    });
  });

  group('инициализация', () {
    test('ключ и параметры доходят до натива', () async {
      await platform.initialize(apiKey: 'key', locale: 'ru');
      expect(initializer.calls.single, 'setup(key, null, ru)');
      expect(await platform.isInitialized(), isTrue);
    });
  });

  group('события', () {
    test('событие приходит подписчику своей карты', () async {
      final List<VkMapEvent> received = <VkMapEvent>[];
      final Stream<VkMapEvent> stream = platform.events(5);
      final StreamSubscription<VkMapEvent> sub = stream.listen(received.add);

      platform.onEvent(
        5,
        PlatformMapEvent(type: PlatformMapEventType.mapShown),
      );
      platform.onEvent(
        5,
        PlatformMapEvent(
          type: PlatformMapEventType.tap,
          position: PlatformLatLon(latitude: 55.0, longitude: 37.0),
          screenPoint: PlatformScreenPoint(x: 10, y: 20),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(2));
      expect(received.first, isA<VkMapShownEvent>());
      expect((received[1] as VkMapTapEvent).screenPoint.x, 10);
      await sub.cancel();
    });

    test('событие чужой карты не попадает в поток', () async {
      final List<VkMapEvent> received = <VkMapEvent>[];
      final StreamSubscription<VkMapEvent> sub = platform
          .events(1)
          .listen(received.add);

      platform.onEvent(
        2,
        PlatformMapEvent(type: PlatformMapEventType.mapShown),
      );
      await Future<void>.delayed(Duration.zero);

      expect(received, isEmpty);
      await sub.cancel();
    });

    test('битое событие не роняет поток', () async {
      final List<VkMapEvent> received = <VkMapEvent>[];
      final StreamSubscription<VkMapEvent> sub = platform
          .events(1)
          .listen(received.add);

      // markerTap без координаты и идентификатора — такого быть не должно,
      // но поток обязан пережить.
      platform.onEvent(
        1,
        PlatformMapEvent(type: PlatformMapEventType.markerTap),
      );
      platform.onEvent(
        1,
        PlatformMapEvent(type: PlatformMapEventType.styleApplied),
      );
      await Future<void>.delayed(Duration.zero);

      expect(received.single, isA<VkStyleAppliedEvent>());
      await sub.cancel();
    });

    test('dispose закрывает поток карты', () async {
      final Stream<VkMapEvent> stream = platform.events(9);
      bool done = false;
      final StreamSubscription<VkMapEvent> sub = stream.listen(
        (_) {},
        onDone: () => done = true,
      );

      await platform.dispose(9);
      await Future<void>.delayed(Duration.zero);

      expect(done, isTrue);
      expect(host.calls, contains('dispose(9)'));
      await sub.cancel();
    });
  });
}
