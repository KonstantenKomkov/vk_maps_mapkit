import 'package:flutter/material.dart';
import 'package:vk_maps_api/vk_maps_api.dart';
import 'package:vk_maps_mapkit/vk_maps_mapkit.dart';

import '../main.dart' show apiKey;

/// Экран изохрон: область достижимости за 15 и 30 минут пешком.
class IsochronesScreen extends StatefulWidget {
  /// Создаёт экран изохрон.
  const IsochronesScreen({super.key});

  @override
  State<IsochronesScreen> createState() => _IsochronesScreenState();
}

class _IsochronesScreenState extends State<IsochronesScreen> {
  static const VkGeoPoint _center = VkGeoPoint(55.796932, 37.537849);

  late final VkMapsApiClient _client = apiKey.isEmpty
      ? VkMapsApiClient.demo()
      : VkMapsApiClient(apiKey: apiKey);

  VkMapController? _controller;
  String _status = 'Нажмите «Показать изохроны»';
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
            target: VkLatLon(_center.latitude, _center.longitude),
            zoom: 13,
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
              onPressed: _loading ? null : _load,
              child: const Text('Показать изохроны'),
            ),
          ],
        ),
      ),
    ],
  );

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _status = 'Считаем область достижимости…';
    });
    try {
      final VkIsochrones isochrones = await _client.routing.isochrones(
        locations: <VkGeoPoint>[_center],
        timeContours: <double>[15, 30],
        colors: <String>['ff0000', '00ff00'],
        costing: VkCosting.pedestrian,
      );

      // Контуры приходят готовым GeoJSON — его же и отдаём карте.
      for (int i = 0; i < isochrones.contours.length; i++) {
        final VkIsochroneContour contour = isochrones.contours[i];
        await _controller?.drawPolygon(
          <VkLatLon>[
            for (final VkGeoPoint point in contour.points)
              VkLatLon(point.latitude, point.longitude),
          ],
          id: 'iso-$i',
          fillColor: '#${contour.color ?? '0077FF'}',
          fillOpacity: 0.25,
        );
      }
      setState(() => _status = 'Контуров: ${isochrones.contours.length}');
    } on VkMapsApiException catch (error) {
      setState(() => _status = 'Ошибка: ${error.message}');
    } finally {
      setState(() => _loading = false);
    }
  }
}
