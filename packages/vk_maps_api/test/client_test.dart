import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:vk_maps_api/vk_maps_api.dart';

void main() {
  group('VkMapsApiClient.buildUri', () {
    test('ключ подставляется в каждый запрос', () {
      final VkMapsApiClient client = VkMapsApiClient(apiKey: 'секрет');
      final Uri uri = client.buildUri('suggest', <String, String?>{'q': 'Мск'});
      expect(uri.queryParameters['api_key'], 'секрет');
      expect(uri.queryParameters['q'], 'Мск');
      expect(uri.path, endsWith('/api/suggest'));
      client.close();
    });

    test('пустые параметры не попадают в адрес', () {
      final VkMapsApiClient client = VkMapsApiClient(apiKey: 'k');
      final Uri uri = client.buildUri('places', <String, String?>{
        'q': 'кафе',
        'lang': null,
      });
      expect(uri.queryParameters.containsKey('lang'), isFalse);
      client.close();
    });

    test('демо-клиент идёт на демо-сервер и без ключа', () {
      final VkMapsApiClient client = VkMapsApiClient.demo();
      final Uri uri = client.buildUri('timezone', <String, String?>{
        'q': '1,2',
      });
      expect(uri.host, 'demo.maps.vk.com');
      expect(uri.queryParameters.containsKey('api_key'), isFalse);
      expect(client.apiKey, isNull);
      client.close();
    });

    test('свой базовый адрес учитывается', () {
      final VkMapsApiClient client = VkMapsApiClient(
        apiKey: 'k',
        baseUrl: Uri.parse('https://example.test/maps/'),
      );
      expect(
        client.buildUri('search').toString(),
        startsWith('https://example.test/maps/search'),
      );
      client.close();
    });
  });

  group('обработка ошибок', () {
    Future<void> expectError(
      int statusCode,
      String body,
      void Function(VkMapsApiException error) check,
    ) async {
      final VkMapsApiClient client = VkMapsApiClient(
        apiKey: 'k',
        httpClient: MockClient(
          (http.Request request) async => http.Response(
            body,
            statusCode,
            headers: <String, String>{
              'content-type': 'application/json; charset=utf-8',
            },
          ),
        ),
      );
      try {
        await client.getJson('suggest');
        fail('Ожидалась ошибка');
      } on VkMapsApiException catch (error) {
        check(error);
      }
    }

    test('429 распознаётся как превышение лимита', () async {
      await expectError(429, '{}', (VkMapsApiException error) {
        expect(error.isRateLimited, isTrue);
        expect(error.message, contains('лимит'));
        expect(error.endpoint, 'suggest');
      });
    });

    test('текст ошибки берётся из конверта сервиса, если он есть', () async {
      // Реальный ответ демо-сервера при превышении лимита.
      await expectError(
        429,
        '{"error": {"status_code": 429, "status": "RPS/EPS limit exceeded."}}',
        (VkMapsApiException error) {
          expect(error.message, 'RPS/EPS limit exceeded.');
          expect(error.isRateLimited, isTrue);
        },
      );
    });

    test('401 распознаётся как отклонённый ключ', () async {
      await expectError(401, 'no', (VkMapsApiException error) {
        expect(error.isUnauthorized, isTrue);
        expect(error.body, 'no');
      });
    });

    test('500 не выдаётся за ошибку клиента', () async {
      await expectError(500, '', (VkMapsApiException error) {
        expect(error.isRateLimited, isFalse);
        expect(error.isUnauthorized, isFalse);
        expect(error.message, contains('сервиса'));
      });
    });

    test('не-JSON в ответе даёт понятную ошибку', () async {
      await expectError(200, '<html>ошибка</html>', (VkMapsApiException error) {
        expect(error.message, contains('не является JSON'));
      });
    });

    test('обрыв соединения оборачивается в VkMapsApiException', () async {
      final VkMapsApiClient client = VkMapsApiClient(
        apiKey: 'k',
        httpClient: MockClient(
          (http.Request request) async =>
              throw http.ClientException("нет сети"),
        ),
      );
      expect(
        () => client.getJson('suggest'),
        throwsA(isA<VkMapsApiException>()),
      );
    });
  });

  group('кодировка', () {
    test('кириллица в ответе читается как UTF-8', () async {
      final VkMapsApiClient client = VkMapsApiClient(
        apiKey: 'k',
        httpClient: MockClient(
          (http.Request request) async => http.Response.bytes(
            utf8.encode('{"request":"тест","results":[]}'),
            200,
          ),
        ),
      );
      final Map<String, dynamic> json = await client.getJson('suggest');
      expect(json['request'], 'тест');
    });
  });
}
