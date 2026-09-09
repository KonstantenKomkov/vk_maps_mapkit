// Фикстура читается с диска, поэтому тест живёт только на виртуальной
// машине: в браузере файловой системы нет.
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:vk_maps_api/vk_maps_api.dart';

({VkMapsApiClient client, List<Map<String, dynamic>> bodies}) clientReturning(
  String body,
) {
  final List<Map<String, dynamic>> bodies = <Map<String, dynamic>>[];
  final VkMapsApiClient client = VkMapsApiClient(
    apiKey: 'k',
    httpClient: MockClient((http.Request request) async {
      bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
      return http.Response.bytes(utf8.encode(body), 200);
    }),
  );
  return (client: client, bodies: bodies);
}

void main() {
  group('/directions на примере из документации', () {
    late VkRoutesResponse response;
    late List<Map<String, dynamic>> bodies;

    setUp(() async {
      final String fixture = File(
        'test/fixtures/directions_response.json',
      ).readAsStringSync();
      final ({VkMapsApiClient client, List<Map<String, dynamic>> bodies}) mock =
          clientReturning(fixture);
      bodies = mock.bodies;
      response = await mock.client.routing.directions(
        <VkRouteLocation>[
          const VkRouteLocation(VkGeoPoint(55.796932, 37.537849), heading: 150),
          const VkRouteLocation(
            VkGeoPoint(55.865625, 37.46229),
            type: VkLocationType.via,
          ),
          const VkRouteLocation(VkGeoPoint(55.962139, 37.406377)),
        ],
        language: 'ru-RU',
        id: 'route_to_airport',
      );
      mock.client.close();
    });

    test('тело запроса собрано по документации', () {
      final Map<String, dynamic> body = bodies.single;
      expect(body['costing'], 'auto');
      expect(body['language'], 'ru-RU');
      expect(body['id'], 'route_to_airport');
      expect(body['directions_type'], 'instructions');
      final List<dynamic> locations = body['locations'] as List<dynamic>;
      expect(locations, hasLength(3));
      expect((locations.first as Map<String, dynamic>)['heading'], 150);
      expect((locations[1] as Map<String, dynamic>)['type'], 'via');
      expect(
        (locations.last as Map<String, dynamic>).containsKey('type'),
        isFalse,
      );
    });

    test('маршрут разобран: время, длина, границы', () {
      final VkRoute route = response.primary!;
      expect(route.summary.length, closeTo(26.583, 0.001));
      expect(route.summary.time.inSeconds, 1444);
      expect(route.summary.boundingBox!.southwest.latitude, 55.79378);
      expect(route.summary.boundingBox!.northeast.longitude, 37.546925);
    });

    test('точки маршрута вернулись с типами', () {
      expect(response.primary!.locations, hasLength(3));
      expect(
        response.primary!.locations.first.latitude,
        closeTo(55.796932, 1e-9),
      );
    });

    test('геометрия раскодирована и лежит в пределах маршрута', () {
      final List<VkGeoPoint> shape = response.primary!.shape;
      expect(shape.length, greaterThan(100));
      for (final VkGeoPoint point in shape) {
        expect(point.latitude, inInclusiveRange(55.79, 55.97));
        expect(point.longitude, inInclusiveRange(37.39, 37.55));
      }
    });

    test('манёвры прочитаны с инструкциями', () {
      final List<VkManeuver> maneuvers =
          response.primary!.legs.single.maneuvers;
      expect(maneuvers, hasLength(20));
      expect(maneuvers.first.instruction, 'Двигайтесь на северо-восток.');
      expect(maneuvers.first.beginShapeIndex, 0);
      expect(maneuvers.first.time.inMilliseconds, 8720);
    });
  });

  group('прочие сервисы маршрутизации', () {
    test('optimal_route кладёт единицы в directions_options', () async {
      final ({VkMapsApiClient client, List<Map<String, dynamic>> bodies}) mock =
          clientReturning('{"trips":[]}');
      await mock.client.routing.optimalRoute(
        <VkRouteLocation>[
          const VkRouteLocation(VkGeoPoint(55.77055, 49.22088)),
          const VkRouteLocation(VkGeoPoint(55.75043, 49.26842)),
        ],
        costing: VkCosting.pedestrian,
        units: VkDistanceUnits.miles,
      );
      final Map<String, dynamic> body = mock.bodies.single;
      expect(body['costing'], 'pedestrian');
      expect(
        (body['directions_options'] as Map<String, dynamic>)['units'],
        'miles',
      );
      mock.client.close();
    });

    test('матрица достижимости разбирается по индексам', () async {
      final ({VkMapsApiClient client, List<Map<String, dynamic>> bodies}) mock =
          clientReturning('''
{
  "id": "DM_Test",
  "sources_to_targets": [
    [
      {"distance": 1.076, "time": 773, "to_index": 0, "from_index": 0},
      {"distance": 1.459, "time": 1041, "to_index": 1, "from_index": 0}
    ]
  ]
}''');
      final VkDistanceMatrix matrix = await mock.client.routing.distanceMatrix(
        sources: <VkGeoPoint>[const VkGeoPoint(55.796932, 37.537849)],
        targets: <VkGeoPoint>[
          const VkGeoPoint(55.790412, 37.534313),
          const VkGeoPoint(55.788644, 37.536507),
        ],
      );

      expect(matrix.id, 'DM_Test');
      expect(matrix.cell(0, 1)!.distance, 1.459);
      expect(matrix.cell(0, 1)!.time, const Duration(seconds: 1041));
      expect(matrix.cell(1, 0), isNull);
      mock.client.close();
    });

    test('матрица отказывается от заведомо превышенного числа точек', () async {
      final ({VkMapsApiClient client, List<Map<String, dynamic>> bodies}) mock =
          clientReturning('{}');
      expect(
        () => mock.client.routing.distanceMatrix(
          sources: List<VkGeoPoint>.filled(30, const VkGeoPoint(55, 37)),
          targets: List<VkGeoPoint>.filled(30, const VkGeoPoint(55, 37)),
        ),
        throwsA(isA<ArgumentError>()),
      );
      mock.client.close();
    });

    test('изохроны собирают контуры и цвета', () async {
      final ({VkMapsApiClient client, List<Map<String, dynamic>> bodies}) mock =
          clientReturning('''
{
  "id": "Iso_Test",
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"contour": 15, "color": "ff0000", "metric": "time"},
      "geometry": {"type": "LineString", "coordinates": [[37.5, 55.7], [37.6, 55.8]]}
    }
  ]
}''');
      final VkIsochrones isochrones = await mock.client.routing.isochrones(
        locations: <VkGeoPoint>[const VkGeoPoint(55.796932, 37.537849)],
        timeContours: <double>[15, 30],
        colors: <String>['ff0000', '00ff00'],
        costing: VkCosting.pedestrian,
      );

      final Map<String, dynamic> body = mock.bodies.single;
      final List<dynamic> contours = body['contours'] as List<dynamic>;
      expect(contours, hasLength(2));
      expect((contours.first as Map<String, dynamic>)['time'], 15);
      expect((contours.first as Map<String, dynamic>)['color'], 'ff0000');

      expect(isochrones.contours.single.metric, 'time');
      expect(isochrones.contours.single.points.first.latitude, 55.7);
      expect(isochrones.raw['type'], 'FeatureCollection');
      mock.client.close();
    });

    test('изохроны без контуров не отправляются', () async {
      final ({VkMapsApiClient client, List<Map<String, dynamic>> bodies}) mock =
          clientReturning('{}');
      expect(
        () => mock.client.routing.isochrones(
          locations: <VkGeoPoint>[const VkGeoPoint(55, 37)],
        ),
        throwsA(isA<ArgumentError>()),
      );
      mock.client.close();
    });
  });
}
