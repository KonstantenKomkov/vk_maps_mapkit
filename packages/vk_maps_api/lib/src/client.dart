import 'dart:convert';

import 'package:http/http.dart' as http;

import 'exceptions.dart';
import 'services/extras.dart';
import 'services/routing.dart';
import 'services/search.dart';
import 'services/static_map.dart';

/// Клиент REST-сервисов VK Карт.
///
/// ```dart
/// final client = VkMapsApiClient(apiKey: 'ключ');
/// final suggestions = await client.search.suggest('Москва Ленинградский');
/// client.close();
/// ```
///
/// Клиент держит одно HTTP-соединение на все сервисы, поэтому его стоит
/// создавать один раз и закрывать через [close].
class VkMapsApiClient {
  /// Создаёт клиент с ключом доступа.
  ///
  /// [baseUrl] по умолчанию — рабочий сервер VK Карт. [httpClient] можно
  /// передать свой: так подставляется мок в тестах или клиент с прокси.
  VkMapsApiClient({
    required String apiKey,
    Uri? baseUrl,
    http.Client? httpClient,
  }) : _apiKey = apiKey,
       _baseUrl = baseUrl ?? Uri.parse('https://maps.vk.com/api/'),
       _http = httpClient ?? http.Client(),
       _ownsHttpClient = httpClient == null;

  /// Создаёт клиент к демонстрационному серверу, работающему без ключа.
  ///
  /// Годится для проб и автотестов; для приложения нужен свой ключ.
  VkMapsApiClient.demo({http.Client? httpClient})
    : _apiKey = null,
      _baseUrl = Uri.parse('https://demo.maps.vk.com/api/'),
      _http = httpClient ?? http.Client(),
      _ownsHttpClient = httpClient == null;

  final String? _apiKey;
  final Uri _baseUrl;
  final http.Client _http;
  final bool _ownsHttpClient;

  /// Поиск, подсказки и геокодирование.
  late final VkSearchApi search = VkSearchApi(this);

  /// Маршруты, изохроны и матрица достижимости.
  late final VkRoutingApi routing = VkRoutingApi(this);

  /// Высоты, местоположение по IP, часовой пояс, почтовый индекс.
  late final VkExtrasApi extras = VkExtrasApi(this);

  /// Ссылки на статичную карту.
  late final VkStaticMapApi staticMap = VkStaticMapApi(this);

  /// Базовый адрес сервера.
  Uri get baseUrl => _baseUrl;

  /// Ключ доступа, если клиент создан с ключом.
  String? get apiKey => _apiKey;

  /// Собирает адрес точки вызова с параметрами и ключом.
  Uri buildUri(String endpoint, [Map<String, String?> query = const {}]) {
    final Map<String, String> parameters = <String, String>{
      for (final MapEntry<String, String?> entry in query.entries)
        if (entry.value != null) entry.key: entry.value!,
      'api_key': ?_apiKey,
    };
    return _baseUrl.resolve(endpoint).replace(queryParameters: parameters);
  }

  /// Выполняет GET и разбирает ответ как JSON-объект.
  Future<Map<String, dynamic>> getJson(
    String endpoint, [
    Map<String, String?> query = const {},
  ]) async {
    final Uri uri = buildUri(endpoint, query);
    final http.Response response;
    try {
      response = await _http.get(uri);
    } on Exception catch (error) {
      throw VkMapsApiException(
        'Не удалось выполнить запрос: $error',
        endpoint: endpoint,
      );
    }
    return _decode(response, endpoint);
  }

  /// Выполняет POST с телом JSON и разбирает ответ как JSON-объект.
  Future<Map<String, dynamic>> postJson(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String?> query = const {},
  }) async {
    final Uri uri = buildUri(endpoint, query);
    final http.Response response;
    try {
      response = await _http.post(
        uri,
        headers: const <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
    } on Exception catch (error) {
      throw VkMapsApiException(
        'Не удалось выполнить запрос: $error',
        endpoint: endpoint,
      );
    }
    return _decode(response, endpoint);
  }

  Map<String, dynamic> _decode(http.Response response, String endpoint) {
    if (response.statusCode >= 400) {
      throw VkMapsApiException(
        _serviceErrorText(response.body) ??
            _errorMessageFor(response.statusCode),
        statusCode: response.statusCode,
        endpoint: endpoint,
        body: response.body,
      );
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException catch (error) {
      throw VkMapsApiException(
        'Ответ не является JSON: ${error.message}',
        statusCode: response.statusCode,
        endpoint: endpoint,
        body: response.body,
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw VkMapsApiException(
        'Ожидался JSON-объект, пришёл ${decoded.runtimeType}',
        statusCode: response.statusCode,
        endpoint: endpoint,
        body: response.body,
      );
    }
    return decoded;
  }

  /// Достаёт текст ошибки из конверта сервиса.
  ///
  /// Формат ошибок в документации не описан; по факту сервис отвечает
  /// `{"error": {"status_code": 429, "status": "RPS/EPS limit exceeded."}}`
  /// — проверено на демо-сервере 8 сентября 2026.
  String? _serviceErrorText(String body) {
    if (body.isEmpty) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> &&
          decoded['error'] is Map<String, dynamic>) {
        final Object? status =
            (decoded['error'] as Map<String, dynamic>)['status'];
        if (status is String && status.isNotEmpty) {
          return status;
        }
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  String _errorMessageFor(int statusCode) => switch (statusCode) {
    401 || 403 => 'Ключ доступа отклонён сервером',
    404 => 'Точка вызова не найдена',
    429 => 'Превышен лимит частоты запросов (по умолчанию 50 в секунду)',
    >= 500 => 'Ошибка на стороне сервиса',
    _ => 'Сервис ответил ошибкой',
  };

  /// Закрывает HTTP-клиент, если он был создан этим объектом.
  void close() {
    if (_ownsHttpClient) {
      _http.close();
    }
  }
}
