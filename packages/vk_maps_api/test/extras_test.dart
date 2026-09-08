import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:vk_maps_api/vk_maps_api.dart';

({VkMapsApiClient client, List<http.Request> requests}) clientReturning(
  String body,
) {
  final List<http.Request> requests = <http.Request>[];
  final VkMapsApiClient client = VkMapsApiClient(
    apiKey: 'k',
    httpClient: MockClient((http.Request request) async {
      requests.add(request);
      return http.Response.bytes(utf8.encode(body), 200);
    }),
  );
  return (client: client, requests: requests);
}

void main() {
  group('/elevation', () {
    test('профиль высот читается, тело — POST с locations', () async {
      final ({VkMapsApiClient client, List<http.Request> requests})
      mock = clientReturning(
        '{"id":"p","shape":[{"lat":55.6,"lon":37.5}],"height":[186.0,190.5]}',
      );
      final VkElevationProfile profile = await mock.client.extras.elevation(
        <VkGeoPoint>[const VkGeoPoint(55.601897, 37.581305)],
        heightPrecision: 2,
      );

      expect(profile.heights, <double>[186.0, 190.5]);
      expect(profile.shape.single.latitude, 55.6);
      final Map<String, dynamic> body =
          jsonDecode(mock.requests.single.body) as Map<String, dynamic>;
      expect(body['height_precision'], 2);
      expect((body['locations'] as List<dynamic>).single, <String, dynamic>{
        'lat': 55.601897,
        'lon': 37.581305,
      });
      expect(mock.requests.single.method, 'POST');
      mock.client.close();
    });

    test('режим range даёт пары «расстояние — высота»', () async {
      final ({VkMapsApiClient client, List<http.Request> requests}) mock =
          clientReturning('{"range_height":[[0,186],[125,188]]}');
      final VkElevationProfile profile = await mock.client.extras.elevation(
        <VkGeoPoint>[const VkGeoPoint(55.6, 37.5)],
        range: true,
      );

      expect(profile.rangeHeights, hasLength(2));
      expect(profile.rangeHeights.last.distance, 125);
      expect(profile.rangeHeights.last.height, 188);
      mock.client.close();
    });

    test('пустой список точек отклоняется до запроса', () async {
      final ({VkMapsApiClient client, List<http.Request> requests}) mock =
          clientReturning('{}');
      expect(
        () => mock.client.extras.elevation(const <VkGeoPoint>[]),
        throwsA(isA<ArgumentError>()),
      );
      expect(mock.requests, isEmpty);
      mock.client.close();
    });
  });

  group('/ip2geo', () {
    test('geo_id из примера читается', () async {
      final ({VkMapsApiClient client, List<http.Request> requests}) mock =
          clientReturning('''
{"request":"/ip2geo","results":[{"address":"Россия, Москва","geo_id":5506,
"isocode":"RU","pin":[37.617494,55.750446],"type":"city",
"bbox":[37.326228,55.491308,37.967428,55.957772]}]}''');
      final VkIpLocation? location = await mock.client.extras.ip2geo(
        '46.138.195.192',
      );

      expect(location!.geoId, 5506);
      expect(location.pin!.latitude, closeTo(55.750446, 1e-9));
      expect(location.boundingBox!.northeast.latitude, 55.957772);
      mock.client.close();
    });

    test('geoid из таблицы документации тоже читается', () async {
      final ({VkMapsApiClient client, List<http.Request> requests}) mock =
          clientReturning('{"results":[{"address":"а","geoid":77}]}');
      final VkIpLocation? location = await mock.client.extras.ip2geo('1.2.3.4');
      expect(location!.geoId, 77);
      mock.client.close();
    });

    test('пустой результат даёт null, а не исключение', () async {
      final ({VkMapsApiClient client, List<http.Request> requests}) mock =
          clientReturning('{"results":[]}');
      expect(await mock.client.extras.ip2geo('1.2.3.4'), isNull);
      mock.client.close();
    });
  });

  group('/timezone и /postcode', () {
    test('часовой пояс читается со смещением', () async {
      final ({VkMapsApiClient client, List<http.Request> requests}) mock =
          clientReturning(
            '{"results":[{"tzid":"Europe/Moscow","utc_delta":10800}]}',
          );
      final VkTimezone? timezone = await mock.client.extras.timezone(
        const VkGeoPoint(55.479205, 37.32733),
      );

      expect(timezone!.id, 'Europe/Moscow');
      expect(timezone.utcOffset, const Duration(hours: 3));
      expect(
        mock.requests.single.url.queryParameters['q'],
        '55.479205,37.32733',
      );
      mock.client.close();
    });

    test('почтовый индекс разбирается по улицам и домам', () async {
      final ({VkMapsApiClient client, List<http.Request> requests}) mock =
          clientReturning('''
{"results":[{"addresses":{"country":"Россия","localities":[
{"name":"Москва","streets":[{"name":"Ленинградский проспект",
"buildings":["39","39 с3"]}]}]}}]}''');
      final VkPostcodeResult? result = await mock.client.extras.postcode(
        '125167',
        fields: <String>['*'],
      );

      expect(result!.country, 'Россия');
      expect(result.localities.single.name, 'Москва');
      expect(result.localities.single.streets.single.buildings, <String>[
        '39',
        '39 с3',
      ]);
      expect(mock.requests.single.url.queryParameters['fields'], '*');
      mock.client.close();
    });
  });

  group('статичная карта', () {
    test('ссылка по центру собирается с булавками', () {
      final VkMapsApiClient client = VkMapsApiClient(apiKey: 'k');
      final Uri uri = client.staticMap.urlForCenter(
        center: const VkGeoPoint(55.73, 37.59),
        zoom: 14,
        width: 640,
        height: 480,
        style: 'dark',
        scale: 2,
        pins: const <VkStaticPin>[
          VkStaticPin(point: VkGeoPoint(55.76, 37.59), icon: 'mail-corp_photo'),
          VkStaticPin(point: VkGeoPoint(55.75, 37.62)),
        ],
      );

      expect(uri.path, endsWith('/staticmap/png'));
      expect(uri.queryParameters['latlon'], '55.73,37.59');
      expect(uri.queryParameters['zoom'], '14');
      expect(uri.queryParameters['scale'], '2');
      expect(
        uri.queryParameters['pins'],
        '55.76,37.59,mail-corp_photo|55.75,37.62',
      );
      client.close();
    });

    test('ссылка по области использует bbox', () {
      final VkMapsApiClient client = VkMapsApiClient.demo();
      final Uri uri = client.staticMap.urlForBounds(
        southwest: const VkGeoPoint(55.7, 37.5),
        northeast: const VkGeoPoint(55.8, 37.7),
      );
      expect(uri.queryParameters['bbox'], '55.7,37.5,55.8,37.7');
      client.close();
    });

    test('недопустимые размеры и зум отклоняются', () {
      final VkMapsApiClient client = VkMapsApiClient(apiKey: 'k');
      expect(
        () => client.staticMap.urlForCenter(
          center: const VkGeoPoint(55, 37),
          zoom: 14,
          width: 2000,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => client.staticMap.urlForCenter(
          center: const VkGeoPoint(55, 37),
          zoom: 20,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => client.staticMap.urlForCenter(
          center: const VkGeoPoint(55, 37),
          zoom: 10,
          scale: 3,
        ),
        throwsA(isA<ArgumentError>()),
      );
      client.close();
    });
  });
}
