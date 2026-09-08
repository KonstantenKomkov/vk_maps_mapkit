import 'package:flutter/material.dart';
import 'package:vk_maps_api/vk_maps_api.dart';

import '../main.dart' show apiKey;

/// Экран статичной карты: картинка без нативного SDK.
class StaticMapScreen extends StatefulWidget {
  /// Создаёт экран статичной карты.
  const StaticMapScreen({super.key});

  @override
  State<StaticMapScreen> createState() => _StaticMapScreenState();
}

class _StaticMapScreenState extends State<StaticMapScreen> {
  late final VkMapsApiClient _client = apiKey.isEmpty
      ? VkMapsApiClient.demo()
      : VkMapsApiClient(apiKey: apiKey);

  int _zoom = 14;

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Uri url = _client.staticMap.urlForCenter(
      center: const VkGeoPoint(55.796932, 37.537849),
      zoom: _zoom,
      width: 640,
      height: 480,
      scale: 2,
      pins: const <VkStaticPin>[
        VkStaticPin(point: VkGeoPoint(55.796932, 37.537849)),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Image.network(
              url.toString(),
              fit: BoxFit.contain,
              errorBuilder: (_, Object error, _) =>
                  Center(child: Text('Не удалось загрузить: $error')),
            ),
          ),
          const SizedBox(height: 12),
          Text('Зум: $_zoom'),
          Slider(
            value: _zoom.toDouble(),
            min: 3,
            max: 17,
            divisions: 14,
            onChanged: (double value) => setState(() => _zoom = value.round()),
          ),
          SelectableText(url.toString(), style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
