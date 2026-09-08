import '../client.dart';
import '../models/geo_point.dart';
import '../models/search.dart';

/// Тип объектов, по которым идёт поиск подсказок.
enum VkSuggestType {
  /// Адреса.
  address,

  /// Места интереса.
  place,
}

/// Административный уровень, которым ограничивается ответ.
enum VkAdminLevel {
  /// Страна.
  country(1),

  /// Регион.
  region(2),

  /// Населённый пункт.
  locality(3),

  /// Улица.
  street(4),

  /// Дом.
  building(5);

  const VkAdminLevel(this.value);

  /// Числовое значение параметра `admin_level`.
  final int value;
}

/// Поиск, подсказки и геокодирование.
///
/// Соответствует разделу документации «Поиск и геокодирование»:
/// `/suggest`, `/places`, `/search`.
class VkSearchApi {
  /// Создаёт сервис поверх клиента.
  VkSearchApi(this._client);

  final VkMapsApiClient _client;

  /// Подсказки при посимвольном вводе — `/suggest`.
  ///
  /// [location] и [radius] сдвигают выдачу к нужной точке; [limit]
  /// принимает значения от 1 до 100, по умолчанию сервис отдаёт 5.
  Future<VkSearchResponse<VkSuggestion>> suggest(
    String query, {
    List<String>? fields,
    List<VkSuggestType>? types,
    String? lang,
    VkGeoPoint? location,
    int? radius,
    VkAdminLevel? adminLevel,
    int? limit,
  }) async {
    final Map<String, dynamic> json = await _client.getJson('suggest', {
      'q': query,
      'fields': fields?.join(','),
      'types': types?.map((VkSuggestType t) => t.name).join(','),
      'lang': lang,
      'location': location?.toQueryValue(),
      'radius': radius?.toString(),
      'admin_level': adminLevel?.value.toString(),
      'limit': limit?.toString(),
    });
    return _envelope(json, VkSuggestion.fromJson);
  }

  /// Поиск мест интереса — `/places`.
  Future<VkSearchResponse<VkPlace>> places(
    String query, {
    List<String>? fields,
    List<String>? types,
    String? lang,
    VkGeoPoint? location,
    int? radius,
    int? limit,
    String? isoCode,
  }) async {
    final Map<String, dynamic> json = await _client.getJson('places', {
      'q': query,
      'fields': fields?.join(','),
      'types': types?.join(','),
      'lang': lang,
      'location': location?.toQueryValue(),
      'radius': radius?.toString(),
      'limit': limit?.toString(),
      'isocode': isoCode,
    });
    return _envelope(json, VkPlace.fromJson);
  }

  /// Прямое геокодирование — `/search` с адресом в запросе.
  Future<VkSearchResponse<VkPlace>> geocode(
    String address, {
    List<String>? fields,
    String? lang,
    int? limit,
    VkAdminLevel? adminLevel,
    VkGeoPoint? location,
    String? isoCode,
    int? radius,
  }) => _search(
    address,
    fields: fields,
    lang: lang,
    limit: limit,
    adminLevel: adminLevel,
    location: location,
    isoCode: isoCode,
    radius: radius,
  );

  /// Обратное геокодирование — `/search` с координатой в запросе.
  Future<VkSearchResponse<VkPlace>> reverseGeocode(
    VkGeoPoint point, {
    List<String>? fields,
    String? lang,
    int? limit,
    VkAdminLevel? adminLevel,
    int? radius,
  }) => _search(
    point.toQueryValue(),
    fields: fields,
    lang: lang,
    limit: limit,
    adminLevel: adminLevel,
    radius: radius,
  );

  Future<VkSearchResponse<VkPlace>> _search(
    String query, {
    List<String>? fields,
    String? lang,
    int? limit,
    VkAdminLevel? adminLevel,
    VkGeoPoint? location,
    String? isoCode,
    int? radius,
  }) async {
    final Map<String, dynamic> json = await _client.getJson('search', {
      'q': query,
      'fields': fields?.join(','),
      'lang': lang,
      'limit': limit?.toString(),
      'admin_level': adminLevel?.value.toString(),
      'location': location?.toQueryValue(),
      'isocode': isoCode,
      'radius': radius?.toString(),
    });
    return _envelope(json, VkPlace.fromJson);
  }

  VkSearchResponse<T> _envelope<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parse,
  ) {
    final Object? results = json['results'];
    return VkSearchResponse<T>(
      request: json['request'] as String? ?? '',
      results: List<T>.unmodifiable(
        results is List<dynamic>
            ? results.whereType<Map<String, dynamic>>().map(parse)
            : const <Never>[],
      ),
    );
  }
}
