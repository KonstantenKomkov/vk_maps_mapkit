import 'package:flutter/material.dart';
import 'package:vk_maps_api/vk_maps_api.dart';
import 'package:vk_maps_mapkit/vk_maps_mapkit.dart';

import '../main.dart' show apiKey;

/// Экран маршрута: REST-запрос и отрисовка ломаной на карте.
class RouteScreen extends StatefulWidget {
  /// Создаёт экран маршрута.
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  static const VkGeoPoint _from = VkGeoPoint(55.796932, 37.537849);
  static const VkGeoPoint _to = VkGeoPoint(55.962139, 37.406377);

  late final VkMapsApiClient _client = apiKey.isEmpty
      ? VkMapsApiClient.demo()
      : VkMapsApiClient(apiKey: apiKey);

  VkMapController? _controller;
  String _status = 'Нажмите «Построить маршрут»';
  bool _loading = false;

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Expanded(
        child: VkMap(
          initialCameraPosition: VkCameraPosition(
            target: VkLatLon(55.88, 37.47),
            zoom: 10,
          ),
          onMapCreated: (VkMapController controller) =>
              _controller = controller,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_status),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loading ? null : _buildRoute,
              child: const Text('Построить маршрут'),
            ),
          ],
        ),
      ),
    ],
  );

  Future<void> _buildRoute() async {
    setState(() {
      _loading = true;
      _status = 'Считаем маршрут…';
    });
    try {
      final VkRoutesResponse response = await _client.routing.directions(
        <VkRouteLocation>[
          const VkRouteLocation(_from),
          const VkRouteLocation(_to),
        ],
        language: 'ru-RU',
      );
      final VkRoute? route = response.primary;
      if (route == null) {
        setState(() => _status = 'Маршрут не построен');
        return;
      }

      // Ломаная отдаётся карте в том же закодированном виде, в каком её
      // прислал сервис: раскодировать и собирать GeoJSON не нужно.
      for (int i = 0; i < route.legs.length; i++) {
        await _controller?.drawRoute(
          route.legs[i].encodedShape,
          id: 'route-$i',
        );
      }
      await _controller?.fitBounds(
        VkLatLonBounds(
          southwest: VkLatLon(
            route.summary.boundingBox?.southwest.latitude ?? _from.latitude,
            route.summary.boundingBox?.southwest.longitude ?? _from.longitude,
          ),
          northeast: VkLatLon(
            route.summary.boundingBox?.northeast.latitude ?? _to.latitude,
            route.summary.boundingBox?.northeast.longitude ?? _to.longitude,
          ),
        ),
        padding: const VkEdgeInsets.all(32),
      );

      setState(() {
        _status =
            '${route.summary.length.toStringAsFixed(1)} км, '
            '${route.summary.time.inMinutes} мин, '
            'манёвров: ${route.legs.fold<int>(0, (int sum, VkRouteLeg leg) => sum + leg.maneuvers.length)}';
      });
    } on VkMapsApiException catch (error) {
      setState(() => _status = 'Ошибка: ${error.message}');
    } finally {
      setState(() => _loading = false);
    }
  }
}
