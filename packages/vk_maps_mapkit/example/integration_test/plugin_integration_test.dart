// Интеграционные тесты примера: запускаются на устройстве или симуляторе.
//
//   flutter test integration_test --dart-define=VK_MAPS_API_KEY=…
//
// Без ключа карта не создаётся, поэтому проверки карты пропускаются: тест
// не должен падать там, где нечего проверять.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vk_maps_mapkit/vk_maps_mapkit.dart';
import 'package:vk_maps_mapkit_example/main.dart';

const String _apiKey = String.fromEnvironment('VK_MAPS_API_KEY');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('приложение поднимается', (WidgetTester tester) async {
    await tester.pumpWidget(const VkMapsExampleApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('VK Карты'), findsWidgets);
  });

  testWidgets('карта создаётся и отдаёт контроллер', (
    WidgetTester tester,
  ) async {
    await VkMaps.init(apiKey: _apiKey, locale: 'ru');
    expect(await VkMaps.isInitialized, isTrue);

    VkMapController? controller;
    await tester.pumpWidget(
      MaterialApp(
        home: VkMap(
          initialCameraPosition: VkCameraPosition(
            target: VkLatLon(55.796932, 37.537849),
            zoom: 13,
          ),
          onMapCreated: (VkMapController c) => controller = c,
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(controller, isNotNull, reason: 'карта не создалась');
  }, skip: _apiKey.isEmpty);

  testWidgets('камера перемещается и возвращает новое положение', (
    WidgetTester tester,
  ) async {
    await VkMaps.init(apiKey: _apiKey, locale: 'ru');
    VkMapController? controller;
    await tester.pumpWidget(
      MaterialApp(
        home: VkMap(
          initialCameraPosition: VkCameraPosition(
            target: VkLatLon(55.796932, 37.537849),
            zoom: 10,
          ),
          onMapCreated: (VkMapController c) => controller = c,
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await controller!.animateCamera(
      target: VkLatLon(59.938784, 30.314997),
      options: const VkCameraOptions(zoom: 14),
      animation: VkAnimationOptions.none,
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final VkCameraPosition position = await controller!.getCameraPosition();
    expect(position.zoom, closeTo(14, 0.5));
    expect(position.target.latitude, closeTo(59.938784, 0.1));
  }, skip: _apiKey.isEmpty);

  testWidgets('маркер добавляется и удаляется без ошибок', (
    WidgetTester tester,
  ) async {
    await VkMaps.init(apiKey: _apiKey, locale: 'ru');
    final List<String> errors = <String>[];
    Set<VkMarker> markers = <VkMarker>{};

    Widget build() => MaterialApp(
      home: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => VkMap(
          initialCameraPosition: VkCameraPosition(
            target: VkLatLon(55.796932, 37.537849),
            zoom: 13,
          ),
          markers: markers,
          onError: (String code, String message) =>
              errors.add('$code: $message'),
        ),
      ),
    );

    await tester.pumpWidget(build());
    await tester.pumpAndSettle(const Duration(seconds: 5));

    markers = <VkMarker>{
      VkMarker(
        markerId: const VkMarkerId('a'),
        position: VkLatLon(55.796932, 37.537849),
        imageId: 'pin',
      ),
    };
    await tester.pumpWidget(build());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    markers = <VkMarker>{};
    await tester.pumpWidget(build());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(errors, isEmpty);
  }, skip: _apiKey.isEmpty);
}
