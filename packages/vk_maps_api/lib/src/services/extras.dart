import '../client.dart';
import '../exceptions.dart';
import '../models/extras.dart';
import '../models/geo_point.dart';

/// Дополнительные сервисы: высоты, IP, часовой пояс, почтовый индекс.
class VkExtrasApi {
  /// Создаёт сервис поверх клиента.
  VkExtrasApi(this._client);

  final VkMapsApiClient _client;

  /// Профиль высот — `/elevation`.
  ///
  /// [range] переключает ответ на пары «расстояние — высота», удобные для
  /// построения профиля; [resampleDistance] разбивает путь на отрезки
  /// заданной длины в метрах.
  Future<VkElevationProfile> elevation(
    List<VkGeoPoint> locations, {
    bool? range,
    int? resampleDistance,
    int? heightPrecision,
    String? id,
  }) async {
    if (locations.isEmpty) {
      throw ArgumentError('Нужна хотя бы одна точка');
    }
    final Map<String, dynamic> json = await _client.postJson('elevation', {
      'locations': locations.map((VkGeoPoint p) => p.toJson()).toList(),
      'range': ?range,
      'resample_distance': ?resampleDistance,
      'height_precision': ?heightPrecision,
      'id': ?id,
    });
    return VkElevationProfile.fromJson(json);
  }

  /// Местоположение по IP-адресу — `/ip2geo`.
  Future<VkIpLocation?> ip2geo(String ip, {String? lang}) async {
    final Map<String, dynamic> json = await _client.getJson('ip2geo', {
      'q': ip,
      'lang': lang,
    });
    final List<VkIpLocation> results = _results(json, VkIpLocation.fromJson);
    return results.isEmpty ? null : results.first;
  }

  /// Часовой пояс точки — `/timezone`.
  Future<VkTimezone?> timezone(VkGeoPoint point) async {
    final Map<String, dynamic> json = await _client.getJson('timezone', {
      'q': point.toQueryValue(),
    });
    final List<VkTimezone> results = _results(json, VkTimezone.fromJson);
    return results.isEmpty ? null : results.first;
  }

  /// Адресная информация по почтовому индексу — `/postcode`.
  Future<VkPostcodeResult?> postcode(
    String code, {
    List<String>? fields,
  }) async {
    final Map<String, dynamic> json = await _client.getJson('postcode', {
      'q': code,
      'fields': fields?.join(','),
    });
    final List<VkPostcodeResult> results = _results(
      json,
      VkPostcodeResult.fromJson,
    );
    return results.isEmpty ? null : results.first;
  }

  List<T> _results<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parse,
  ) {
    final Object? results = json['results'];
    if (results is! List<dynamic>) {
      throw VkMapsApiException(
        'В ответе нет списка results',
        body: json.toString(),
      );
    }
    return results.whereType<Map<String, dynamic>>().map(parse).toList();
  }
}
