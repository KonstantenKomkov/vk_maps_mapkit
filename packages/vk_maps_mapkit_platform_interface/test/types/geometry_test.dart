import 'package:flutter_test/flutter_test.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';

void main() {
  group('VkLatLon', () {
    test('широта ограничивается диапазоном −90…90', () {
      expect(VkLatLon(120, 30).latitude, 90);
      expect(VkLatLon(-120, 30).latitude, -90);
    });

    test('долгота приводится к −180…180', () {
      expect(VkLatLon(0, 190).longitude, -170);
      expect(VkLatLon(0, -190).longitude, 170);
      expect(VkLatLon(0, 540).longitude, 180 - 360);
      expect(VkLatLon(0, 180).longitude, -180);
      expect(VkLatLon(0, -180).longitude, -180);
    });

    test('значения внутри диапазона не меняются', () {
      final VkLatLon point = VkLatLon(55.796932, 37.537849);
      expect(point.latitude, 55.796932);
      expect(point.longitude, 37.537849);
    });

    test('равенство по значению', () {
      expect(VkLatLon(55.0, 37.0), VkLatLon(55.0, 37.0));
      expect(VkLatLon(55.0, 37.0).hashCode, VkLatLon(55.0, 37.0).hashCode);
      expect(VkLatLon(55.0, 37.0), isNot(VkLatLon(55.0, 38.0)));
    });
  });

  group('VkLatLonBounds', () {
    final VkLatLonBounds moscow = VkLatLonBounds(
      southwest: VkLatLon(55.5, 37.3),
      northeast: VkLatLon(56.0, 37.9),
    );

    test('содержит точку внутри', () {
      expect(moscow.contains(VkLatLon(55.75, 37.6)), isTrue);
    });

    test('не содержит точку снаружи', () {
      expect(moscow.contains(VkLatLon(55.75, 38.5)), isFalse);
      expect(moscow.contains(VkLatLon(54.0, 37.6)), isFalse);
    });

    test('область через 180-й меридиан', () {
      final VkLatLonBounds pacific = VkLatLonBounds(
        southwest: VkLatLon(-10, 170),
        northeast: VkLatLon(10, -170),
      );
      expect(pacific.crossesAntimeridian, isTrue);
      expect(pacific.contains(VkLatLon(0, 175)), isTrue);
      expect(pacific.contains(VkLatLon(0, -175)), isTrue);
      expect(pacific.contains(VkLatLon(0, 0)), isFalse);
    });

    test('перевёрнутые широты запрещены', () {
      expect(
        () => VkLatLonBounds(
          southwest: VkLatLon(56, 37),
          northeast: VkLatLon(55, 38),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('VkEdgeInsets', () {
    test('all задаёт все стороны', () {
      const VkEdgeInsets insets = VkEdgeInsets.all(8);
      expect(insets.left, 8);
      expect(insets.top, 8);
      expect(insets.right, 8);
      expect(insets.bottom, 8);
    });

    test('равенство по значению', () {
      expect(
        const VkEdgeInsets.all(4),
        const VkEdgeInsets(left: 4, top: 4, right: 4, bottom: 4),
      );
      expect(VkEdgeInsets.zero, const VkEdgeInsets());
    });
  });

  group('VkCameraPosition', () {
    test('copyWith меняет только заданное', () {
      final VkCameraPosition position = VkCameraPosition(
        target: VkLatLon(55.0, 37.0),
        zoom: 12,
        bearing: 30,
        pitch: 15,
      );
      final VkCameraPosition moved = position.copyWith(zoom: 14);
      expect(moved.zoom, 14);
      expect(moved.target, position.target);
      expect(moved.bearing, 30);
      expect(moved.pitch, 15);
    });
  });

  group('VkCameraOptions', () {
    test('пустой набор виден как пустой', () {
      expect(const VkCameraOptions().isEmpty, isTrue);
      expect(const VkCameraOptions(zoom: 10).isEmpty, isFalse);
    });
  });
}
