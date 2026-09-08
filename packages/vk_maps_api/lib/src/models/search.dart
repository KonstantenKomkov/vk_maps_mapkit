import 'package:meta/meta.dart';

import 'geo_point.dart';

/// Детализация адреса, разложенная по административным уровням.
@immutable
class VkAddressDetails {
  /// Создаёт детализацию адреса.
  const VkAddressDetails({
    this.country,
    this.isoCode,
    this.region,
    this.subregion,
    this.locality,
    this.sublocality,
    this.suburb,
    this.street,
    this.building,
    this.postalCode,
  });

  /// Разбирает объект `address_details`.
  factory VkAddressDetails.fromJson(Map<String, dynamic> json) =>
      VkAddressDetails(
        country: json['country'] as String?,
        isoCode: json['isocode'] as String?,
        region: json['region'] as String?,
        subregion: json['subregion'] as String?,
        locality: json['locality'] as String?,
        sublocality: json['sublocality'] as String?,
        suburb: json['suburb'] as String?,
        street: json['street'] as String?,
        building: json['building'] as String?,
        postalCode: json['postal_code'] as String?,
      );

  /// Страна.
  final String? country;

  /// Двухбуквенный код страны по ISO 3166-1 alpha-2.
  final String? isoCode;

  /// Область.
  final String? region;

  /// Район области.
  final String? subregion;

  /// Населённый пункт.
  final String? locality;

  /// Микрорайон или жилой комплекс.
  final String? sublocality;

  /// Район населённого пункта.
  final String? suburb;

  /// Улица.
  final String? street;

  /// Номер дома или строения.
  final String? building;

  /// Почтовый индекс.
  final String? postalCode;

  @override
  String toString() =>
      'VkAddressDetails($country, $locality, $street, $building)';
}

/// Подсказка сервиса `/suggest`.
@immutable
class VkSuggestion {
  /// Создаёт подсказку.
  const VkSuggestion({
    required this.address,
    this.name,
    this.type,
    this.ref,
    this.addressDetails,
  });

  /// Разбирает элемент ответа `/suggest`.
  factory VkSuggestion.fromJson(Map<String, dynamic> json) => VkSuggestion(
    address: json['address'] as String? ?? '',
    name: json['name'] as String?,
    type: json['type'] as String?,
    ref: json['ref'] as String?,
    addressDetails: json['address_details'] is Map<String, dynamic>
        ? VkAddressDetails.fromJson(
            json['address_details'] as Map<String, dynamic>,
          )
        : null,
  );

  /// Полный адрес одной строкой.
  final String address;

  /// Название объекта.
  final String? name;

  /// Тип объекта.
  final String? type;

  /// Идентификатор объекта. Нестабилен: сохранять его надолго нельзя.
  final String? ref;

  /// Детализация адреса, если запрошено поле `address_details`.
  final VkAddressDetails? addressDetails;

  @override
  String toString() => 'VkSuggestion($address)';
}

/// Геометрия найденного объекта.
@immutable
class VkGeometry {
  /// Создаёт геометрию.
  const VkGeometry({required this.type, required this.coordinates});

  /// Разбирает объект `geometry`.
  factory VkGeometry.fromJson(Map<String, dynamic> json) {
    final List<VkGeoPoint> points = <VkGeoPoint>[];
    void collect(Object? node) {
      if (node is List<dynamic>) {
        if (node.length >= 2 && node[0] is num && node[1] is num) {
          points.add(VkGeoPoint.fromPin(node));
          return;
        }
        for (final Object? child in node) {
          collect(child);
        }
      }
    }

    collect(json['coordinates']);
    return VkGeometry(
      type: json['type'] as String? ?? 'Unknown',
      coordinates: List<VkGeoPoint>.unmodifiable(points),
    );
  }

  /// Тип геометрии: `Point`, `LineString`, `Polygon` и подобные.
  final String type;

  /// Точки геометрии, развёрнутые в плоский список.
  final List<VkGeoPoint> coordinates;

  @override
  String toString() => 'VkGeometry($type, точек: ${coordinates.length})';
}

/// Найденный объект: место интереса или результат геокодирования.
@immutable
class VkPlace {
  /// Создаёт найденный объект.
  const VkPlace({
    required this.address,
    this.name,
    this.type,
    this.ref,
    this.pin,
    this.boundingBox,
    this.geometry,
    this.addressDetails,
    this.entrances = const <VkGeoPoint>[],
    this.raw = const <String, dynamic>{},
  });

  /// Разбирает элемент ответа `/places` или `/search`.
  factory VkPlace.fromJson(Map<String, dynamic> json) => VkPlace(
    address: json['address'] as String? ?? '',
    name: json['name'] as String?,
    type: json['type'] as String?,
    ref: json['ref'] as String?,
    pin: json['pin'] is List<dynamic>
        ? VkGeoPoint.fromPin(json['pin'] as List<dynamic>)
        : null,
    boundingBox: json['bbox'] is List<dynamic>
        ? VkBoundingBox.fromBbox(json['bbox'] as List<dynamic>)
        : null,
    geometry: json['geometry'] is Map<String, dynamic>
        ? VkGeometry.fromJson(json['geometry'] as Map<String, dynamic>)
        : null,
    addressDetails: json['address_details'] is Map<String, dynamic>
        ? VkAddressDetails.fromJson(
            json['address_details'] as Map<String, dynamic>,
          )
        : null,
    entrances: _parseEntrances(json['entrances']),
    raw: json,
  );

  /// Полный адрес одной строкой.
  final String address;

  /// Название объекта.
  final String? name;

  /// Тип объекта.
  final String? type;

  /// Идентификатор объекта. Нестабилен.
  final String? ref;

  /// Координата объекта.
  final VkGeoPoint? pin;

  /// Границы объекта для позиционирования карты.
  final VkBoundingBox? boundingBox;

  /// Геометрия объекта.
  final VkGeometry? geometry;

  /// Детализация адреса.
  final VkAddressDetails? addressDetails;

  /// Входы в здание.
  ///
  /// В документации порядок координат у входов записан как `[lat, lon]`,
  /// в отличие от остальных полей `pin`. Здесь порядок определяется по
  /// значениям: широта по модулю не превышает 90.
  final List<VkGeoPoint> entrances;

  /// Исходный JSON объекта: сервис отдаёт больше полей, чем описано в
  /// документации, и они могут понадобиться приложению.
  final Map<String, dynamic> raw;

  static List<VkGeoPoint> _parseEntrances(Object? value) {
    if (value is! List<dynamic>) {
      return const <VkGeoPoint>[];
    }
    final List<VkGeoPoint> result = <VkGeoPoint>[];
    for (final Object? item in value) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final Object? pin = item['pin'];
      if (pin is! List<dynamic> || pin.length < 2) {
        continue;
      }
      final double first = (pin[0] as num).toDouble();
      final double second = (pin[1] as num).toDouble();
      // Документация противоречит себе: в таблице pin — [lon, lat], а в
      // примере входов — [lat, lon]. Определяем по значению: широта не
      // бывает больше 90 по модулю.
      final bool firstLooksLikeLatitude =
          first.abs() <= 90 && second.abs() > 90;
      result.add(
        firstLooksLikeLatitude
            ? VkGeoPoint(first, second)
            : VkGeoPoint(second, first),
      );
    }
    return List<VkGeoPoint>.unmodifiable(result);
  }

  @override
  String toString() => 'VkPlace(${name ?? address})';
}

/// Ответ сервисов поиска: конверт `{request, results}`.
@immutable
class VkSearchResponse<T> {
  /// Создаёт ответ.
  const VkSearchResponse({required this.request, required this.results});

  /// Строка запроса, как её увидел сервис.
  final String request;

  /// Найденные объекты.
  final List<T> results;

  @override
  String toString() => 'VkSearchResponse(${results.length} результатов)';
}
