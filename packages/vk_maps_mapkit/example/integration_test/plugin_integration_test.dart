// Интеграционные тесты примера. Запуск:
//   flutter test integration_test
// Сейчас проверяют только, что приложение поднимается; проверки карты
// добавляются по мере реализации плагина.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vk_maps_mapkit_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('приложение примера запускается', (WidgetTester tester) async {
    await tester.pumpWidget(const VkMapsExampleApp());
    expect(find.text('VK Карты'), findsOneWidget);
  });
}
