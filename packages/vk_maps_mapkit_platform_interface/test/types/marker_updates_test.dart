import 'package:flutter_test/flutter_test.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';

VkMarker _marker(String id, {double lat = 55.0, String image = 'pin'}) =>
    VkMarker(
      markerId: VkMarkerId(id),
      position: VkLatLon(lat, 37.0),
      imageId: image,
    );

void main() {
  group('VkMarkerUpdates', () {
    test('одинаковые наборы дают пустую дельту', () {
      final VkMarkerUpdates updates = VkMarkerUpdates.from(
        <VkMarker>{_marker('a'), _marker('b')},
        <VkMarker>{_marker('a'), _marker('b')},
      );
      expect(updates.isEmpty, isTrue);
      expect(updates.isNotEmpty, isFalse);
    });

    test('новый маркер попадает в добавляемые', () {
      final VkMarkerUpdates updates = VkMarkerUpdates.from(
        <VkMarker>{_marker('a')},
        <VkMarker>{_marker('a'), _marker('b')},
      );
      expect(updates.objectsToAdd.single.markerId, const VkMarkerId('b'));
      expect(updates.objectsToChange, isEmpty);
      expect(updates.objectIdsToRemove, isEmpty);
    });

    test('исчезнувший маркер попадает в удаляемые', () {
      final VkMarkerUpdates updates = VkMarkerUpdates.from(
        <VkMarker>{_marker('a'), _marker('b')},
        <VkMarker>{_marker('a')},
      );
      expect(updates.objectIdsToRemove, <VkMarkerId>{const VkMarkerId('b')});
      expect(updates.objectsToAdd, isEmpty);
      expect(updates.objectsToChange, isEmpty);
    });

    test('изменённый маркер попадает в изменяемые, а не в добавляемые', () {
      final VkMarkerUpdates updates = VkMarkerUpdates.from(
        <VkMarker>{_marker('a')},
        <VkMarker>{_marker('a', lat: 56.0)},
      );
      expect(updates.objectsToChange.single.position.latitude, 56.0);
      expect(updates.objectsToAdd, isEmpty);
      expect(updates.objectIdsToRemove, isEmpty);
    });

    test('смена картинки тоже считается изменением', () {
      final VkMarkerUpdates updates = VkMarkerUpdates.from(
        <VkMarker>{_marker('a')},
        <VkMarker>{_marker('a', image: 'pin-selected')},
      );
      expect(updates.objectsToChange.single.imageId, 'pin-selected');
    });

    test('добавление, изменение и удаление одной дельтой', () {
      final VkMarkerUpdates updates = VkMarkerUpdates.from(
        <VkMarker>{_marker('a'), _marker('b')},
        <VkMarker>{_marker('a', lat: 56.0), _marker('c')},
      );
      expect(updates.objectsToAdd.single.markerId, const VkMarkerId('c'));
      expect(updates.objectsToChange.single.markerId, const VkMarkerId('a'));
      expect(updates.objectIdsToRemove, <VkMarkerId>{const VkMarkerId('b')});
    });

    test('идентификаторы разных типов не равны друг другу', () {
      expect(
        const VkMapsObjectId<VkMarker>('a'),
        isNot(const VkMapsObjectId<String>('a')),
      );
    });
  });
}
