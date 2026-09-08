import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vk_maps_api/vk_maps_api.dart';

import '../main.dart' show apiKey;

/// Экран поиска: подсказки при вводе и геокодирование.
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

  @override
  void dispose() {
    _debounce?.cancel();
    _input.dispose();
    _client.close();
    super.dispose();
  }

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
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        Expanded(
          child: ListView.separated(
            itemCount: _suggestions.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final VkSuggestion suggestion = _suggestions[index];
              return ListTile(
                title: Text(suggestion.name ?? suggestion.address),
                subtitle: Text(suggestion.address),
                trailing: Text(suggestion.type ?? ''),
                onTap: () => _geocode(suggestion.address),
              );
            },
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

  Future<void> _geocode(String address) async {
    try {
      final VkSearchResponse<VkPlace> response = await _client.search.geocode(
        address,
        fields: <String>['address', 'pin', 'bbox', 'type'],
        limit: 1,
      );
      final VkPlace? place = response.results.firstOrNull;
      if (!mounted) {
        return;
      }
      final VkGeoPoint? pin = place?.pin;
      setState(
        () => _error = pin == null
            ? 'Координаты не найдены'
            : 'Координаты: ${pin.latitude}, ${pin.longitude}',
      );
    } on VkMapsApiException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }
}
