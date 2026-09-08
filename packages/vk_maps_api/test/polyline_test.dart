import 'package:test/test.dart';
import 'package:vk_maps_api/vk_maps_api.dart';

void main() {
  group('VkPolyline.decode', () {
    test('пустая строка даёт пустой список', () {
      expect(VkPolyline.decode(''), isEmpty);
    });

    test('одна точка', () {
      // Начало ломаной из ответа /directions. Оно не совпадает с точкой
      // запроса (55.796932, 37.537849) точь-в-точь: маршрут привязан к
      // дороге, поэтому допуск здесь порядка сотни метров.
      final List<VkGeoPoint> points = VkPolyline.decode('ydqliBeqcrfA');
      expect(points, hasLength(1));
      expect(points.single.latitude, closeTo(55.796932, 0.001));
      expect(points.single.longitude, closeTo(37.537849, 0.001));
    });

    test('порядок в результате — широта, долгота', () {
      final List<VkGeoPoint> points = VkPolyline.decode('ydqliBeqcrfA_KyO');
      expect(points, hasLength(2));
      for (final VkGeoPoint point in points) {
        expect(point.latitude, inInclusiveRange(55, 56));
        expect(point.longitude, inInclusiveRange(37, 38));
      }
    });

    test('точки идут по возрастанию расстояния от начала', () {
      final List<VkGeoPoint> points = VkPolyline.decode(
        'ydqliBeqcrfA_KyO_AyA{EsHv^aeA',
      );
      expect(points.length, greaterThan(2));
      expect(points.first.latitude, closeTo(55.796932, 0.001));
    });

    test('обрыв строки — понятная ошибка, а не молчаливый мусор', () {
      expect(
        () => VkPolyline.decode('ydqliBeqcrfA_'),
        throwsA(isA<FormatException>()),
      );
    });

    test('другая точность меняет масштаб', () {
      final List<VkGeoPoint> withE5 = VkPolyline.decode(
        'ydqliBeqcrfA',
        precision: 1e5,
      );
      expect(withE5.single.latitude, closeTo(557.968, 0.01));
    });
  });
}
