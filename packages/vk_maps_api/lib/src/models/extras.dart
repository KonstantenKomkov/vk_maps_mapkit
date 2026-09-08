import 'package:meta/meta.dart';

import 'geo_point.dart';

/// Профиль высот: точки маршрута с высотами над уровнем моря.
@immutable
class VkElevationProfile {
  /// Создаёт профиль.
  const VkElevationProfile({
    required this.heights,
    this.shape = const <VkGeoPoint>[],
    this.rangeHeights = const <VkElevationRange>[],
    this.id,
  });

  /// Разбирает ответ `/elevation`.
  factory VkElevationProfile.fromJson(Map<String, dynamic> json) {
    final List<VkElevationRange> ranges = <VkElevationRange>[];
    final Object? rangeHeight = json['range_height'];
    if (rangeHeight is List<dynamic>) {
      for (final Object? pair in rangeHeight) {
        if (pair is List<dynamic> && pair.length >= 2) {
          ranges.add(
            VkElevationRange(
              distance: (pair[0] as num).toDouble(),
              height: (pair[1] as num).toDouble(),
            ),
          );
        }
      }
    }
    return VkElevationProfile(
      heights: List<double>.unmodifiable(
        (json['height'] as List<dynamic>?)?.whereType<num>().map(
              (num h) => h.toDouble(),
            ) ??
            const <double>[],
      ),
      shape: List<VkGeoPoint>.unmodifiable(
        (json['shape'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map(VkGeoPoint.fromJson) ??
            const <VkGeoPoint>[],
      ),
      rangeHeights: List<VkElevationRange>.unmodifiable(ranges),
      id: json['id'] as String?,
    );
  }

  /// Высоты в метрах — по одной на точку запроса.
  final List<double> heights;

  /// Точки, для которых считались высоты.
  final List<VkGeoPoint> shape;

  /// Пары «расстояние от предыдущей точки, высота», если запрошен `range`.
  final List<VkElevationRange> rangeHeights;

  /// Идентификатор запроса.
  final String? id;

  @override
  String toString() => 'VkElevationProfile(точек: ${heights.length})';
}

/// Пара «расстояние — высота» в профиле высот.
@immutable
class VkElevationRange {
  /// Создаёт пару.
  const VkElevationRange({required this.distance, required this.height});

  /// Расстояние от предыдущей точки в метрах.
  final double distance;

  /// Высота в метрах.
  final double height;

  @override
  String toString() => 'VkElevationRange($distance м, $height м)';
}

/// Местоположение, определённое по IP-адресу.
@immutable
class VkIpLocation {
  /// Создаёт местоположение.
  const VkIpLocation({
    required this.address,
    this.pin,
    this.boundingBox,
    this.geoId,
    this.isoCode,
    this.type,
    this.ref,
  });

  /// Разбирает элемент ответа `/ip2geo`.
  ///
  /// Идентификатор региона в документации назван `geoid`, а в примере
  /// ответа — `geo_id`; читаются оба варианта.
  factory VkIpLocation.fromJson(Map<String, dynamic> json) => VkIpLocation(
    address: json['address'] as String? ?? '',
    pin: json['pin'] is List<dynamic>
        ? VkGeoPoint.fromPin(json['pin'] as List<dynamic>)
        : null,
    boundingBox: json['bbox'] is List<dynamic>
        ? VkBoundingBox.fromBbox(json['bbox'] as List<dynamic>)
        : null,
    geoId:
        (json['geo_id'] as num?)?.toInt() ?? (json['geoid'] as num?)?.toInt(),
    isoCode: json['isocode'] as String?,
    type: json['type'] as String?,
    ref: json['ref'] as String?,
  );

  /// Адрес одной строкой.
  final String address;

  /// Координата центра области.
  final VkGeoPoint? pin;

  /// Границы области.
  final VkBoundingBox? boundingBox;

  /// Идентификатор региона.
  final int? geoId;

  /// Код страны по ISO 3166-1 alpha-2.
  final String? isoCode;

  /// Тип объекта.
  final String? type;

  /// Идентификатор объекта.
  final String? ref;

  @override
  String toString() => 'VkIpLocation($address)';
}

/// Часовой пояс точки.
@immutable
class VkTimezone {
  /// Создаёт часовой пояс.
  const VkTimezone({required this.id, required this.utcOffset});

  /// Разбирает элемент ответа `/timezone`.
  factory VkTimezone.fromJson(Map<String, dynamic> json) => VkTimezone(
    id: json['tzid'] as String? ?? '',
    utcOffset: Duration(seconds: (json['utc_delta'] as num?)?.toInt() ?? 0),
  );

  /// Идентификатор пояса в базе IANA, например `Europe/Moscow`.
  final String id;

  /// Смещение относительно UTC.
  final Duration utcOffset;

  @override
  String toString() => 'VkTimezone($id, $utcOffset)';
}

/// Адресная информация по почтовому индексу.
@immutable
class VkPostcodeResult {
  /// Создаёт результат.
  const VkPostcodeResult({
    required this.country,
    required this.localities,
    this.raw = const <String, dynamic>{},
  });

  /// Разбирает элемент ответа `/postcode`.
  factory VkPostcodeResult.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> addresses =
        json['addresses'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final List<VkPostcodeLocality> localities = <VkPostcodeLocality>[];
    final Object? rawLocalities = addresses['localities'];
    if (rawLocalities is List<dynamic>) {
      for (final Object? locality in rawLocalities) {
        if (locality is Map<String, dynamic>) {
          localities.add(VkPostcodeLocality.fromJson(locality));
        }
      }
    }
    return VkPostcodeResult(
      country: addresses['country'] as String? ?? '',
      localities: List<VkPostcodeLocality>.unmodifiable(localities),
      raw: json,
    );
  }

  /// Страна.
  final String country;

  /// Населённые пункты с улицами и домами.
  final List<VkPostcodeLocality> localities;

  /// Исходный JSON.
  final Map<String, dynamic> raw;

  @override
  String toString() => 'VkPostcodeResult($country, ${localities.length})';
}

/// Населённый пункт в ответе по индексу.
@immutable
class VkPostcodeLocality {
  /// Создаёт населённый пункт.
  const VkPostcodeLocality({required this.name, required this.streets});

  /// Разбирает элемент `localities`.
  factory VkPostcodeLocality.fromJson(Map<String, dynamic> json) {
    final List<VkPostcodeStreet> streets = <VkPostcodeStreet>[];
    final Object? rawStreets = json['streets'];
    if (rawStreets is List<dynamic>) {
      for (final Object? street in rawStreets) {
        if (street is Map<String, dynamic>) {
          streets.add(VkPostcodeStreet.fromJson(street));
        }
      }
    }
    return VkPostcodeLocality(
      name: json['name'] as String? ?? '',
      streets: List<VkPostcodeStreet>.unmodifiable(streets),
    );
  }

  /// Название населённого пункта.
  final String name;

  /// Улицы.
  final List<VkPostcodeStreet> streets;

  @override
  String toString() => 'VkPostcodeLocality($name)';
}

/// Улица в ответе по индексу.
@immutable
class VkPostcodeStreet {
  /// Создаёт улицу.
  const VkPostcodeStreet({required this.name, required this.buildings});

  /// Разбирает элемент `streets`.
  factory VkPostcodeStreet.fromJson(Map<String, dynamic> json) =>
      VkPostcodeStreet(
        name: json['name'] as String? ?? '',
        buildings: List<String>.unmodifiable(
          (json['buildings'] as List<dynamic>?)?.whereType<String>() ??
              const <String>[],
        ),
      );

  /// Название улицы.
  final String name;

  /// Номера домов.
  final List<String> buildings;

  @override
  String toString() => 'VkPostcodeStreet($name, домов: ${buildings.length})';
}
