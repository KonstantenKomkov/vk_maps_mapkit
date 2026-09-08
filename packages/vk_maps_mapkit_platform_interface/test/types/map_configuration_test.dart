import 'package:flutter_test/flutter_test.dart';
import 'package:vk_maps_mapkit_platform_interface/vk_maps_mapkit_platform_interface.dart';

void main() {
  group('VkMapConfiguration.diffFrom', () {
    test('одинаковые настройки дают пустую дельту', () {
      const VkMapConfiguration config = VkMapConfiguration(
        compassEnabled: true,
        minZoom: 3,
      );
      expect(config.diffFrom(config).isEmpty, isTrue);
    });

    test('в дельту попадает только изменённое поле', () {
      const VkMapConfiguration previous = VkMapConfiguration(
        compassEnabled: true,
        zoomButtonsEnabled: true,
      );
      const VkMapConfiguration current = VkMapConfiguration(
        compassEnabled: false,
        zoomButtonsEnabled: true,
      );
      final VkMapConfiguration diff = current.diffFrom(previous);
      expect(diff.compassEnabled, isFalse);
      expect(diff.zoomButtonsEnabled, isNull);
      expect(diff.isNotEmpty, isTrue);
    });

    test('смена стиля видна в дельте', () {
      const VkMapConfiguration previous = VkMapConfiguration(
        style: VkMapStyle.predefined(VkPredefinedStyle.main),
      );
      const VkMapConfiguration current = VkMapConfiguration(
        style: VkMapStyle.predefined(VkPredefinedStyle.dark),
      );
      expect(
        current.diffFrom(previous).style,
        const VkMapStyle.predefined(VkPredefinedStyle.dark),
      );
    });

    test('одинаковый JSON-стиль дельты не даёт', () {
      const VkMapConfiguration config = VkMapConfiguration(
        style: VkMapStyle.json('{"version":8}'),
      );
      expect(config.diffFrom(config).style, isNull);
    });

    test('пустая конфигурация пуста', () {
      expect(const VkMapConfiguration().isEmpty, isTrue);
    });
  });
}
