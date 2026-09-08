/// Клиент REST-сервисов VK Карт на чистом Dart.
///
/// Пакет не зависит от Flutter: подходит для консольных приложений и
/// сервера. Покрывает подсказки, поиск мест, геокодирование, маршруты,
/// изохроны, матрицу достижимости, профиль высот, определение по IP,
/// часовой пояс, почтовый индекс и ссылки на статичную карту.
///
/// ```dart
/// final client = VkMapsApiClient(apiKey: 'ключ');
/// final response = await client.search.suggest('Москва Ленинградский');
/// client.close();
/// ```
library;

export 'src/client.dart';
export 'src/exceptions.dart';
export 'src/models/extras.dart';
export 'src/models/geo_point.dart';
export 'src/models/routing.dart';
export 'src/models/search.dart';
export 'src/polyline.dart';
export 'src/services/extras.dart';
export 'src/services/routing.dart';
export 'src/services/search.dart';
export 'src/services/static_map.dart';
