import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:vk_maps_api/vk_maps_api.dart';

/// Клиент, отвечающий заранее заданным телом и запоминающий запрос.
({VkMapsApiClient client, List<Uri> requests}) clientReturning(String body) {
  final List<Uri> requests = <Uri>[];
  final VkMapsApiClient client = VkMapsApiClient(
    apiKey: 'k',
    httpClient: MockClient((http.Request request) async {
      requests.add(request.url);
      return http.Response.bytes(utf8.encode(body), 200);
    }),
  );
  return (client: client, requests: requests);
}

void main() {
  group('/suggest', () {
    test('конверт разбирается, поля читаются', () async {
      final ({VkMapsApiClient client, List<Uri> requests}) mock =
          clientReturning('''
{
  "request": "/v3/suggest?limit=2",
  "results": [
    {
      "address": "Россия, Москва, Ленинградский проспект, 39 с79",
      "name": "Ленинградский проспект, 39 с79",
      "type": "building"
    }
  ]
}''');
      final VkSearchResponse<VkSuggestion> response = await mock.client.search
          .suggest(
            'Москва Ленинградский 39',
            limit: 2,
            types: <VkSuggestType>[VkSuggestType.address, VkSuggestType.place],
            location: const VkGeoPoint(55.796743, 37.537354),
          );

      expect(response.results.single.name, 'Ленинградский проспект, 39 с79');
      expect(response.results.single.type, 'building');
      expect(response.request, contains('suggest'));

      final Uri uri = mock.requests.single;
      expect(uri.queryParameters['limit'], '2');
      expect(uri.queryParameters['types'], 'address,place');
      expect(uri.queryParameters['location'], '55.796743,37.537354');
      mock.client.close();
    });

    test('пустой список результатов не роняет разбор', () async {
      final ({VkMapsApiClient client, List<Uri> requests}) mock =
          clientReturning('{"request":"q","results":[]}');
      final VkSearchResponse<VkSuggestion> response = await mock.client.search
          .suggest('нет такого');
      expect(response.results, isEmpty);
      mock.client.close();
    });
  });

  group('/places и /search', () {
    test('pin разворачивается из [lon, lat] в широту и долготу', () async {
      final ({VkMapsApiClient client, List<Uri> requests}) mock =
          clientReturning('''
{
  "request": "/places",
  "results": [
    {
      "address": "Россия, Москва",
      "name": "Прайм",
      "type": "cafe",
      "pin": [37.537354, 55.796743],
      "bbox": [37.5, 55.7, 37.6, 55.8]
    }
  ]
}''');
      final VkSearchResponse<VkPlace> response = await mock.client.search
          .places('прайм');
      final VkPlace place = response.results.single;

      expect(place.pin!.latitude, closeTo(55.796743, 1e-9));
      expect(place.pin!.longitude, closeTo(37.537354, 1e-9));
      expect(place.boundingBox!.southwest.latitude, 55.7);
      expect(place.boundingBox!.northeast.longitude, 37.6);
      mock.client.close();
    });

    test('обратное геокодирование шлёт координату в q', () async {
      final ({VkMapsApiClient client, List<Uri> requests}) mock =
          clientReturning('{"request":"/search","results":[]}');
      await mock.client.search.reverseGeocode(
        const VkGeoPoint(55.796668, 37.538871),
      );
      expect(mock.requests.single.queryParameters['q'], '55.796668,37.538871');
      expect(mock.requests.single.path, endsWith('/search'));
      mock.client.close();
    });

    test(
      'входы в здание читаются как [lon, lat], вопреки примеру в доке',
      () async {
        // Проверено на демо-сервере: сервис отдаёт [lon, lat], хотя пример в
        // документации показывает обратный порядок.
        final ({VkMapsApiClient client, List<Uri> requests}) mock =
            clientReturning('''
{
  "request": "/search",
  "results": [
    {
      "address": "дом",
      "entrances": [ {"pin": [37.4475714, 55.8621913], "type": "main"} ]
    }
  ]
}''');
        final VkSearchResponse<VkPlace> response = await mock.client.search
            .geocode('дом');
        final VkGeoPoint entrance = response.results.single.entrances.single;

        expect(entrance.latitude, closeTo(55.8621913, 1e-9));
        expect(entrance.longitude, closeTo(37.4475714, 1e-9));
        mock.client.close();
      },
    );

    test('геометрия разворачивается в плоский список точек', () async {
      final ({VkMapsApiClient client, List<Uri> requests}) mock =
          clientReturning('''
{
  "request": "/search",
  "results": [
    {
      "address": "полигон",
      "geometry": {
        "type": "Polygon",
        "coordinates": [[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0]]]
      }
    }
  ]
}''');
      final VkSearchResponse<VkPlace> response = await mock.client.search
          .geocode('полигон');
      final VkGeometry geometry = response.results.single.geometry!;

      expect(geometry.type, 'Polygon');
      expect(geometry.coordinates, hasLength(3));
      expect(geometry.coordinates.first.longitude, 100.0);
      expect(geometry.coordinates.first.latitude, 0.0);
      mock.client.close();
    });

    test('сырой JSON объекта сохраняется целиком', () async {
      final ({VkMapsApiClient client, List<Uri> requests})
      mock = clientReturning(
        '{"request":"/places","results":[{"address":"а","place_details":{"phone":"+7"}}]}',
      );
      final VkSearchResponse<VkPlace> response = await mock.client.search
          .places('а');
      expect(
        response.results.single.raw['place_details'],
        isA<Map<String, dynamic>>(),
      );
      mock.client.close();
    });
  });
}
