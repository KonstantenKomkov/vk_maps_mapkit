import 'package:flutter/material.dart';
import 'package:vk_maps_mapkit/vk_maps_mapkit.dart';

/// Экран карты: камера, маркеры, стиль, события.
class MapScreen extends StatefulWidget {
  /// Создаёт экран карты.
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static final VkLatLon _center = VkLatLon(55.796932, 37.537849);

  VkMapController? _controller;
  VkPredefinedStyle _style = VkPredefinedStyle.main;
  Set<VkMarker> _markers = <VkMarker>{};
  String _status = 'Карта не создана';

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Expanded(
        child: VkMap(
          initialCameraPosition: VkCameraPosition(target: _center, zoom: 13),
          style: VkMapStyle.predefined(_style),
          markers: _markers,
          compassEnabled: true,
          zoomButtonsEnabled: true,
          onMapCreated: (VkMapController controller) {
            _controller = controller;
            setState(() => _status = 'Карта готова');
          },
          onTap: (VkLatLon position) => _addMarker(position),
          onMarkerTap: (VkMarkerId id) =>
              setState(() => _status = 'Маркер ${id.value}'),
          onCameraIdle: (VkCameraPosition position) => setState(
            () => _status = 'Зум ${position.zoom.toStringAsFixed(1)}',
          ),
          onError: (String code, String message) =>
              setState(() => _status = 'Ошибка $code: $message'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_status),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton.tonal(
                  onPressed: () => _controller?.animateCamera(
                    target: _center,
                    options: const VkCameraOptions(zoom: 15),
                  ),
                  child: const Text('К центру'),
                ),
                FilledButton.tonal(
                  onPressed: () => _controller?.zoomBy(1),
                  child: const Text('Ближе'),
                ),
                FilledButton.tonal(
                  onPressed: () => _controller?.zoomBy(-1),
                  child: const Text('Дальше'),
                ),
                FilledButton.tonal(
                  onPressed: _toggleStyle,
                  child: Text(
                    _style == VkPredefinedStyle.main
                        ? 'Тёмный стиль'
                        : 'Светлый стиль',
                  ),
                ),
                FilledButton.tonal(
                  onPressed: _markers.isEmpty
                      ? null
                      : () => setState(() => _markers = <VkMarker>{}),
                  child: const Text('Убрать маркеры'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Коснитесь карты, чтобы поставить маркер. Логотип VK убрать '
              'нельзя — его можно только сдвинуть.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    ],
  );

  void _addMarker(VkLatLon position) {
    setState(() {
      _markers = <VkMarker>{
        ..._markers,
        VkMarker(
          markerId: VkMarkerId('m${_markers.length + 1}'),
          position: position,
          imageId: 'pin',
        ),
      };
      _status = 'Маркеров: ${_markers.length}';
    });
  }

  void _toggleStyle() => setState(() {
    _style = _style == VkPredefinedStyle.main
        ? VkPredefinedStyle.dark
        : VkPredefinedStyle.main;
  });
}
