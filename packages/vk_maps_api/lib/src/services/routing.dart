import '../client.dart';
import '../models/geo_point.dart';
import '../models/routing.dart';

/// Маршруты, изохроны и матрица достижимости.
///
/// Соответствует разделу документации «Маршрутизация»: `/directions`,
/// `/optimal_route`, `/dm`, `/iso`. Все запросы — POST с телом JSON.
class VkRoutingApi {
  /// Создаёт сервис поверх клиента.
  VkRoutingApi(this._client);

  final VkMapsApiClient _client;

  /// Построение маршрута — `/directions`.
  ///
  /// Точки проходятся в заданном порядке. [alternates] запрашивает до
  /// четырёх альтернатив, [avoidLocations] — участки, которых нужно
  /// избегать.
  Future<VkRoutesResponse> directions(
    List<VkRouteLocation> locations, {
    VkCosting costing = VkCosting.auto,
    Map<String, dynamic>? costingOptions,
    VkDistanceUnits? units,
    String? language,
    String? id,
    bool withInstructions = true,
    List<VkGeoPoint>? avoidLocations,
    int? alternates,
    bool? alternatesMultiPoints,
    String? completeness,
  }) async {
    final Map<String, dynamic> json = await _client.postJson('directions', {
      'locations': locations.map((VkRouteLocation l) => l.toJson()).toList(),
      'costing': costing.name,
      if (costingOptions != null)
        'costing_options': <String, dynamic>{costing.name: costingOptions},
      if (units != null) 'units': units.value,
      'language': ?language,
      'id': ?id,
      'directions_type': withInstructions ? 'instructions' : 'none',
      if (avoidLocations != null)
        'avoid_locations': avoidLocations
            .map((VkGeoPoint p) => p.toJson())
            .toList(),
      'alternates': ?alternates,
      'alternates_multi_points': ?alternatesMultiPoints,
      'completeness': ?completeness,
    });
    return VkRoutesResponse.fromJson(json);
  }

  /// Оптимальный маршрут — `/optimal_route`.
  ///
  /// В отличие от [directions], сервис сам выбирает порядок обхода точек.
  Future<VkRoutesResponse> optimalRoute(
    List<VkRouteLocation> locations, {
    VkCosting costing = VkCosting.auto,
    Map<String, dynamic>? costingOptions,
    VkDistanceUnits? units,
    String? language,
    String? id,
  }) async {
    final Map<String, dynamic> json = await _client.postJson('optimal_route', {
      'locations': locations.map((VkRouteLocation l) => l.toJson()).toList(),
      'costing': costing.name,
      if (costingOptions != null)
        'costing_options': <String, dynamic>{costing.name: costingOptions},
      if (units != null)
        'directions_options': <String, dynamic>{'units': units.value},
      'language': ?language,
      'id': ?id,
    });
    return VkRoutesResponse.fromJson(json);
  }

  /// Матрица достижимости — `/dm`.
  ///
  /// Суммарное число точек в [sources] и [targets] не должно превышать 50.
  Future<VkDistanceMatrix> distanceMatrix({
    required List<VkGeoPoint> sources,
    required List<VkGeoPoint> targets,
    VkCosting costing = VkCosting.auto,
    Map<String, dynamic>? costingOptions,
    String? id,
  }) async {
    if (sources.length + targets.length > 50) {
      throw ArgumentError(
        'Суммарно точек отправления и назначения не больше 50, передано '
        '${sources.length + targets.length}',
      );
    }
    final Map<String, dynamic> json = await _client.postJson('dm', {
      'sources': sources.map((VkGeoPoint p) => p.toJson()).toList(),
      'targets': targets.map((VkGeoPoint p) => p.toJson()).toList(),
      'costing': costing.name,
      if (costingOptions != null)
        'costing_options': <String, dynamic>{costing.name: costingOptions},
      'id': ?id,
    });
    return VkDistanceMatrix.fromJson(json);
  }

  /// Область достижимости — `/iso`.
  ///
  /// [timeContours] задаётся в минутах, [distanceContours] — в километрах;
  /// хотя бы один из наборов должен быть непустым.
  Future<VkIsochrones> isochrones({
    required List<VkGeoPoint> locations,
    List<double> timeContours = const <double>[],
    List<double> distanceContours = const <double>[],
    List<String> colors = const <String>[],
    VkCosting costing = VkCosting.auto,
    Map<String, dynamic>? costingOptions,
    bool? polygons,
    double? denoise,
    double? generalize,
    String? id,
  }) async {
    if (timeContours.isEmpty && distanceContours.isEmpty) {
      throw ArgumentError('Нужен хотя бы один контур: по времени или по пути');
    }
    final List<Map<String, dynamic>> contours = <Map<String, dynamic>>[
      for (int i = 0; i < timeContours.length; i++)
        <String, dynamic>{
          'time': timeContours[i],
          if (i < colors.length) 'color': colors[i],
        },
      for (int i = 0; i < distanceContours.length; i++)
        <String, dynamic>{
          'distance': distanceContours[i],
          if (timeContours.length + i < colors.length)
            'color': colors[timeContours.length + i],
        },
    ];
    final Map<String, dynamic> json = await _client.postJson('iso', {
      'locations': locations.map((VkGeoPoint p) => p.toJson()).toList(),
      'costing': costing.name,
      if (costingOptions != null)
        'costing_options': <String, dynamic>{costing.name: costingOptions},
      'contours': contours,
      'polygons': ?polygons,
      'denoise': ?denoise,
      'generalize': ?generalize,
      'id': ?id,
    });
    return VkIsochrones.fromJson(json);
  }
}
