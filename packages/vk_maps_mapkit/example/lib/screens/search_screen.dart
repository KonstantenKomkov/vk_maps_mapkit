import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vk_maps_api/vk_maps_api.dart';
import 'package:vk_maps_mapkit/vk_maps_mapkit.dart';

import '../main.dart' show apiKey;
import '../pin_image.dart';

/// Экран поиска: подсказки при вводе, геокодирование и найденное место на
/// карте.
///
/// Экран показывает связку двух пакетов: `vk_maps_api` ищет место, а
/// `vk_maps_mapkit` показывает его — маркером и вписыванием границ объекта
/// в видимую часть карты.
class SearchScreen extends StatefulWidget {
  /// Создаёт экран поиска.
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final VkMapsApiClient _client = apiKey.isEmpty
      ? VkMapsApiClient.demo()
      : VkMapsApiClient(apiKey: apiKey);
  final TextEditingController _input = TextEditingController();

  Timer? _debounce;
  List<VkSuggestion> _suggestions = <VkSuggestion>[];
  String? _error;

  /// Место, найденное по выбранной подсказке.
  VkPlace? _place;

  /// Идёт ли геокодирование выбранной подсказки.
  bool _geocoding = false;

  VkMapController? _controller;
  Set<VkMarker> _markers = const <VkMarker>{};

  @override
  void dispose() {
    _debounce?.cancel();
    _input.dispose();
    _client.close();
    super.dispose();
  }

  /// Камера при первом показе, пока ничего не найдено.
  static final VkCameraPosition _initialCamera = VkCameraPosition(
    target: VkLatLon(55.75, 37.62),
    zoom: 9,
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _input,
          decoration: const InputDecoration(
            labelText: 'Адрес или место',
            hintText: 'Москва Ленинградский 39',
            border: OutlineInputBorder(),
          ),
          onChanged: _onChanged,
        ),
        const SizedBox(height: 12),
        if (_geocoding) const LinearProgressIndicator(),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        // Результат выбора показывается отдельной карточкой: раньше
        // координаты писались в ту же строку, что и ошибки, красным — и
        // выбор подсказки выглядел так, будто ничего не произошло.
        if (_place case final VkPlace place) _PlaceCard(place: place),
        // Подсказки перекрывают карту, пока идёт ввод: на узком экране
        // иначе не помещаются оба списка.
        if (_suggestions.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: Material(
              elevation: 1,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int index) {
                  final VkSuggestion suggestion = _suggestions[index];
                  return ListTile(
                    dense: true,
                    title: Text(suggestion.name ?? suggestion.address),
                    subtitle: Text(
                      suggestion.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(suggestion.type ?? ''),
                    onTap: () => unawaited(_select(suggestion)),
                  );
                },
              ),
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: VkMap(
              initialCameraPosition: _initialCamera,
              style: const VkMapStyle.predefined(VkPredefinedStyle.main),
              markers: _markers,
              zoomButtonsEnabled: true,
              onMapCreated: (VkMapController controller) {
                _controller = controller;
                unawaited(addPinImage(controller));
              },
              onStyleApplied: () {
                final VkMapController? controller = _controller;
                if (controller != null) {
                  unawaited(addPinImage(controller));
                }
              },
              onError: (String code, String message) =>
                  setState(() => _error = 'Карта: $code — $message'),
            ),
          ),
        ),
      ],
    ),
  );

  void _onChanged(String value) {
    // Запрос уходит не на каждый символ: иначе лимит в 50 запросов в
    // секунду выбирается вводом одной строки.
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() => _suggestions = <VkSuggestion>[]);
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(_suggest(value)),
    );
  }

  Future<void> _suggest(String query) async {
    try {
      final VkSearchResponse<VkSuggestion> response = await _client.search
          .suggest(query, limit: 10);
      if (!mounted) {
        return;
      }
      setState(() {
        _suggestions = response.results;
        _error = null;
      });
    } on VkMapsApiException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  /// Выбор подсказки: геокодируем адрес и показываем место на карте.
  Future<void> _select(VkSuggestion suggestion) async {
    // Список закрывается: он перекрывает карту, ради которой и делался
    // выбор. Текст ставится программно, поэтому подсказки не запрашиваются
    // заново.
    _input.text = suggestion.name ?? suggestion.address;
    setState(() => _suggestions = const <VkSuggestion>[]);

    final VkPlace? place = await _geocode(suggestion.address);
    if (place == null || !mounted) {
      return;
    }
    await _showOnMap(place);
  }

  /// Геокодирует адрес и возвращает найденное место.
  Future<VkPlace?> _geocode(String address) async {
    setState(() {
      _geocoding = true;
      _error = null;
      _place = null;
    });
    try {
      final VkSearchResponse<VkPlace> response = await _client.search.geocode(
        address,
        fields: <String>['address', 'pin', 'bbox', 'type'],
        limit: 1,
      );
      final VkPlace? place = response.results.firstOrNull;
      if (!mounted) {
        return null;
      }
      setState(() {
        _place = place;
        _error = place == null ? 'Место не найдено' : null;
      });
      return place;
    } on VkMapsApiException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => _geocoding = false);
      }
    }
  }

  /// Ставит маркер и подводит камеру к найденному месту.
  ///
  /// Границы объекта (`bbox`) точнее одной точки: город так виден целиком,
  /// а дом — крупно. Границы приходят не всегда и иногда вырождаются в
  /// точку — тогда камера идёт к точке с масштабом по типу объекта, иначе
  /// карта прыгнула бы вплотную к земле.
  Future<void> _showOnMap(VkPlace place) async {
    final VkGeoPoint? pin = place.pin;
    if (pin == null) {
      return;
    }
    final VkLatLon target = VkLatLon(pin.latitude, pin.longitude);
    setState(() {
      _markers = <VkMarker>{
        VkMarker(
          markerId: const VkMarkerId('found'),
          position: target,
          imageId: pinImageId,
        ),
      };
    });

    final VkMapController? controller = _controller;
    if (controller == null) {
      return;
    }
    const VkAnimationOptions animation = VkAnimationOptions(
      duration: Duration(milliseconds: 500),
    );

    final VkLatLonBounds? bounds = _boundsAround(target, place);
    if (bounds != null) {
      await controller.fitBounds(
        bounds,
        padding: const VkEdgeInsets.all(48),
        animation: animation,
      );
      return;
    }
    await controller.animateCamera(
      target: target,
      options: VkCameraOptions(zoom: _zoomFor(place.type)),
      animation: animation,
    );
  }

  /// Границы вокруг найденной точки, если объекту есть чем их задать.
  ///
  /// Это не тот прямоугольник, что пришёл в ответе: `pin` объекта редко
  /// совпадает с центром его `bbox` — у города точка стоит на площади, а
  /// границы уходят к окраинам. Прямоугольник строится симметрично вокруг
  /// точки по большему отступу до края, поэтому выбранное место
  /// оказывается ровно в центре карты, а объект целиком остаётся видимым.
  ///
  /// `null` означает, что границ нет или они вырождены в точку: тогда
  /// камера идёт к точке с масштабом по типу объекта.
  static VkLatLonBounds? _boundsAround(VkLatLon target, VkPlace place) {
    final VkBoundingBox? bbox = place.boundingBox;
    if (bbox == null) {
      return null;
    }
    final double halfHeight = math.max(
      (target.latitude - bbox.southwest.latitude).abs(),
      (bbox.northeast.latitude - target.latitude).abs(),
    );
    final double halfWidth = math.max(
      (target.longitude - bbox.southwest.longitude).abs(),
      (bbox.northeast.longitude - target.longitude).abs(),
    );
    // Половина сотой доли градуса — около полукилометра по широте: меньше
    // этого границы считаем точкой.
    if (halfHeight < 0.005 && halfWidth < 0.005) {
      return null;
    }
    return VkLatLonBounds(
      southwest: VkLatLon(
        target.latitude - halfHeight,
        target.longitude - halfWidth,
      ),
      northeast: VkLatLon(
        target.latitude + halfHeight,
        target.longitude + halfWidth,
      ),
    );
  }

  /// Масштаб по типу объекта из ответа геокодера.
  static double _zoomFor(String? type) => switch (type) {
    'country' => 5,
    'region' || 'province' => 7,
    'area' || 'district' => 10,
    'city' || 'locality' || 'town' || 'village' => 12,
    'street' => 16,
    'building' || 'house' || 'address' => 17,
    _ => 14,
  };
}

/// Карточка найденного места: что вернуло геокодирование.
class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place});

  final VkPlace place;

  @override
  Widget build(BuildContext context) {
    final VkGeoPoint? pin = place.pin;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              place.name ?? place.address,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (place.name != null) Text(place.address),
            const SizedBox(height: 4),
            Text(
              pin == null
                  ? 'Координаты не пришли'
                  : 'Координаты: ${pin.latitude.toStringAsFixed(6)}, '
                        '${pin.longitude.toStringAsFixed(6)}',
            ),
            if (place.type case final String type) Text('Тип: $type'),
          ],
        ),
      ),
    );
  }
}
