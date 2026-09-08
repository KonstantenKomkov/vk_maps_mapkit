import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vk_maps_mapkit/vk_maps_mapkit.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart'
    show VkMapConfiguration, VkMapsPlatform;

import 'fake_vk_maps_platform.dart';

VkMarker _marker(String id, {double lat = 55.0, String image = 'pin'}) =>
    VkMarker(
      markerId: VkMarkerId(id),
      position: VkLatLon(lat, 37.0),
      imageId: image,
    );

void main() {
  late FakeVkMapsPlatform platform;

  setUp(() {
    platform = FakeVkMapsPlatform();
    VkMapsPlatform.instance = platform;
  });

  tearDown(() async {
    await platform.close();
  });

  Widget wrap(Widget child) =>
      Directionality(textDirection: TextDirection.ltr, child: child);

  testWidgets('карта создаётся и отдаёт контроллер', (
    WidgetTester tester,
  ) async {
    VkMapController? controller;
    await tester.pumpWidget(
      wrap(
        VkMap(
          initialCameraPosition: VkCameraPosition(target: VkLatLon(55.0, 37.0)),
          onMapCreated: (VkMapController c) => controller = c,
        ),
      ),
    );

    expect(controller, isNotNull);
    expect(controller!.viewId, 1);
    expect(
      platform.lastInitialConfiguration!.initialCameraPosition.target,
      VkLatLon(55.0, 37.0),
    );
  });

  testWidgets('начальные маркеры уходят одной дельтой', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        VkMap(
          initialCameraPosition: VkCameraPosition(target: VkLatLon(55.0, 37.0)),
          markers: <VkMarker>{_marker('a'), _marker('b')},
        ),
      ),
    );

    expect(platform.calls, contains('updateMarkers(1, +2 ~0 -0)'));
  });

  testWidgets('повторная сборка с теми же параметрами не идёт в натив', (
    WidgetTester tester,
  ) async {
    final VkMap map = VkMap(
      initialCameraPosition: VkCameraPosition(target: VkLatLon(55.0, 37.0)),
      markers: <VkMarker>{_marker('a')},
    );

    await tester.pumpWidget(wrap(map));
    platform.calls.clear();
    await tester.pumpWidget(
      wrap(
        VkMap(
          initialCameraPosition: VkCameraPosition(target: VkLatLon(55.0, 37.0)),
          markers: <VkMarker>{_marker('a')},
        ),
      ),
    );

    expect(
      platform.calls.where((String c) => c != 'buildView'),
      isEmpty,
      reason: 'одинаковые наборы не должны порождать вызовов моста',
    );
  });

  testWidgets('изменение маркера уходит как изменение, а не как добавление', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        VkMap(
          initialCameraPosition: VkCameraPosition(target: VkLatLon(55.0, 37.0)),
          markers: <VkMarker>{_marker('a')},
        ),
      ),
    );
    platform.calls.clear();

    await tester.pumpWidget(
      wrap(
        VkMap(
          initialCameraPosition: VkCameraPosition(target: VkLatLon(55.0, 37.0)),
          markers: <VkMarker>{_marker('a', lat: 56.0), _marker('b')},
        ),
      ),
    );

    expect(platform.calls, contains('updateMarkers(1, +1 ~1 -0)'));
    expect(
      platform.lastMarkerUpdates!.objectsToChange.single.markerId,
      const VkMarkerId('a'),
    );
  });

  testWidgets('смена стиля уходит дельтой только со стилем', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        VkMap(
          initialCameraPosition: VkCameraPosition(target: VkLatLon(55.0, 37.0)),
          style: const VkMapStyle.predefined(VkPredefinedStyle.main),
        ),
      ),
    );
    platform.calls.clear();

    await tester.pumpWidget(
      wrap(
        VkMap(
          initialCameraPosition: VkCameraPosition(target: VkLatLon(55.0, 37.0)),
          style: const VkMapStyle.predefined(VkPredefinedStyle.dark),
        ),
      ),
    );

    expect(platform.calls, contains('updateConfiguration(1)'));
    final VkMapConfiguration diff = platform.lastConfiguration!;
    expect(diff.style, const VkMapStyle.predefined(VkPredefinedStyle.dark));
    expect(diff.compassEnabled, isNull);
    expect(diff.padding, isNull);
  });

  testWidgets('события доходят до колбэков', (WidgetTester tester) async {
    final List<String> log = <String>[];
    await tester.pumpWidget(
      wrap(
        VkMap(
          initialCameraPosition: VkCameraPosition(target: VkLatLon(55.0, 37.0)),
          onTap: (VkLatLon p) => log.add('tap'),
          onLongTap: (VkLatLon p) => log.add('longTap'),
          onMarkerTap: (VkMarkerId id) => log.add('marker:${id.value}'),
          onCameraMove: (VkCameraPosition p) => log.add('move'),
          onCameraIdle: (VkCameraPosition p) => log.add('idle'),
          onStyleApplied: () => log.add('style'),
          onError: (String code, String message) => log.add('error:$code'),
        ),
      ),
    );

    platform
      ..emit(
        1,
        VkMapTapEvent(
          position: VkLatLon(55.0, 37.0),
          screenPoint: const VkScreenPoint(1, 1),
        ),
      )
      ..emit(
        1,
        VkMapTapEvent(
          position: VkLatLon(55.0, 37.0),
          screenPoint: const VkScreenPoint(1, 1),
          isLongTap: true,
        ),
      )
      ..emit(
        1,
        VkMarkerTapEvent(
          markerId: const VkMarkerId('a'),
          position: VkLatLon(55.0, 37.0),
        ),
      )
      ..emit(
        1,
        VkCameraMoveEvent(
          position: VkCameraPosition(target: VkLatLon(55.0, 37.0)),
          reason: VkCameraMovingReason.gesture,
          phase: VkCameraMovingPhase.allCompleted,
        ),
      )
      ..emit(1, const VkStyleAppliedEvent())
      ..emit(1, const VkMapErrorEvent(code: 'net', message: 'нет сети'));
    await tester.pump();

    expect(log, <String>[
      'tap',
      'longTap',
      'marker:a',
      'move',
      'idle',
      'style',
      'error:net',
    ]);
  });

  testWidgets('удаление виджета освобождает карту', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        VkMap(
          initialCameraPosition: VkCameraPosition(target: VkLatLon(55.0, 37.0)),
        ),
      ),
    );
    await tester.pumpWidget(wrap(const SizedBox.shrink()));
    await tester.pump();

    expect(platform.calls, contains('dispose(1)'));
  });

  testWidgets('контроллер обращается к своей карте', (
    WidgetTester tester,
  ) async {
    VkMapController? controller;
    await tester.pumpWidget(
      wrap(
        VkMap(
          initialCameraPosition: VkCameraPosition(target: VkLatLon(55.0, 37.0)),
          onMapCreated: (VkMapController c) => controller = c,
        ),
      ),
    );
    platform.calls.clear();

    await controller!.animateCamera(
      target: VkLatLon(56.0, 37.0),
      options: const VkCameraOptions(zoom: 15),
    );
    await controller!.setMode(VkMapMode.followLocation);

    expect(platform.calls, <String>[
      'moveCamera(1, 56.0, 15.0)',
      'setMode(1, followLocation)',
    ]);
  });

  testWidgets('zoomBy читает текущий зум и сдвигает его', (
    WidgetTester tester,
  ) async {
    VkMapController? controller;
    await tester.pumpWidget(
      wrap(
        VkMap(
          initialCameraPosition: VkCameraPosition(target: VkLatLon(55.0, 37.0)),
          onMapCreated: (VkMapController c) => controller = c,
        ),
      ),
    );
    platform.calls.clear();

    await controller!.zoomBy(2);

    expect(platform.calls, <String>[
      'getCameraPosition(1)',
      'moveCamera(1, null, 12.0)',
    ]);
  });
}
