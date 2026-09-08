import 'package:flutter/material.dart';

void main() => runApp(const VkMapsExampleApp());

/// Демонстрационное приложение плагина `vk_maps_mapkit`.
class VkMapsExampleApp extends StatelessWidget {
  /// Создаёт приложение примера.
  const VkMapsExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'VK Карты — пример',
    theme: ThemeData(colorSchemeSeed: const Color(0xFF0077FF)),
    home: Scaffold(
      appBar: AppBar(title: const Text('VK Карты')),
      body: const Center(
        child: Text('Экраны появятся по мере реализации плагина'),
      ),
    ),
  );
}
