import 'package:flutter/material.dart';
import 'package:vk_maps_mapkit/vk_maps_mapkit.dart';

import 'screens/isochrones_screen.dart';
import 'screens/map_screen.dart';
import 'screens/route_screen.dart';
import 'screens/search_screen.dart';
import 'screens/static_map_screen.dart';

/// Ключ доступа передаётся при запуске:
/// `flutter run --dart-define=VK_MAPS_API_KEY=…`
///
/// Без ключа пример работает на демонстрационном сервере: REST-сервисы там
/// доступны, но карта требует настоящий ключ.
const String apiKey = String.fromEnvironment('VK_MAPS_API_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (apiKey.isNotEmpty) {
    await VkMaps.init(apiKey: apiKey, locale: 'ru');
  }
  runApp(const VkMapsExampleApp());
}

/// Демонстрационное приложение плагина `vk_maps_mapkit`.
class VkMapsExampleApp extends StatelessWidget {
  /// Создаёт приложение примера.
  const VkMapsExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'VK Карты',
    theme: ThemeData(colorSchemeSeed: const Color(0xFF0077FF)),
    home: const _HomeScreen(),
  );
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  int _index = 0;

  static const List<_Tab> _tabs = <_Tab>[
    _Tab('Карта', Icons.map_outlined, MapScreen()),
    _Tab('Маршрут', Icons.alt_route, RouteScreen()),
    _Tab('Поиск', Icons.search, SearchScreen()),
    _Tab('Изохроны', Icons.timelapse, IsochronesScreen()),
    _Tab('Статичная', Icons.image_outlined, StaticMapScreen()),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('VK Карты — ${_tabs[_index].title}'),
      bottom: apiKey.isEmpty
          ? const PreferredSize(
              preferredSize: Size.fromHeight(28),
              child: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Ключ не задан: карта не появится, REST работает на демо-сервере',
                ),
              ),
            )
          : null,
    ),
    body: IndexedStack(
      index: _index,
      children: <Widget>[for (final _Tab tab in _tabs) tab.screen],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (int index) => setState(() => _index = index),
      destinations: <Widget>[
        for (final _Tab tab in _tabs)
          NavigationDestination(icon: Icon(tab.icon), label: tab.title),
      ],
    ),
  );
}

class _Tab {
  const _Tab(this.title, this.icon, this.screen);

  final String title;
  final IconData icon;
  final Widget screen;
}
