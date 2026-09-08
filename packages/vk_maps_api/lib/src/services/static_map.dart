import '../client.dart';
import '../models/geo_point.dart';

/// Булавка на статичной карте.
class VkStaticPin {
  /// Создаёт булавку.
  const VkStaticPin({required this.point, this.icon});

  /// Координата булавки.
  final VkGeoPoint point;

  /// Символ булавки из коллекции сервиса.
  final String? icon;

  /// Значение для GET-параметра `pins`.
  String toQueryValue() =>
      icon == null ? point.toQueryValue() : '${point.toQueryValue()},$icon';

  /// Тело булавки для POST-запроса.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'coord': point.toJson(),
    if (icon != null) 'icon': <String, dynamic>{'symbol': icon},
  };
}

/// Статичная карта — `/staticmap/png`.
///
/// Для нескольких булавок GET-ссылка быстро упирается в ограничение длины
/// URL, поэтому есть и POST-вариант, возвращающий изображение телом ответа.
class VkStaticMapApi {
  /// Создаёт сервис поверх клиента.
  VkStaticMapApi(this._client);

  final VkMapsApiClient _client;

  /// Ссылка на изображение карты с центром в [center].
  ///
  /// [width] и [height] — от 32 до 1024 пикселей, [zoom] — от 0 до 17,
  /// [scale] — 1 или 2.
  Uri urlForCenter({
    required VkGeoPoint center,
    required int zoom,
    int width = 512,
    int height = 512,
    String? style,
    int? scale,
    int? padding,
    List<VkStaticPin> pins = const <VkStaticPin>[],
  }) {
    _checkSize(width, height);
    _checkZoom(zoom);
    _checkScale(scale);
    return _client.buildUri('staticmap/png', <String, String?>{
      'latlon': center.toQueryValue(),
      'zoom': '$zoom',
      'width': '$width',
      'height': '$height',
      'style': ?style,
      if (scale != null) 'scale': '$scale',
      if (padding != null) 'padding': '$padding',
      if (pins.isNotEmpty)
        'pins': pins.map((VkStaticPin p) => p.toQueryValue()).join('|'),
    });
  }

  /// Ссылка на изображение карты, вписанной в область.
  Uri urlForBounds({
    required VkGeoPoint southwest,
    required VkGeoPoint northeast,
    int width = 512,
    int height = 512,
    String? style,
    int? scale,
    int? padding,
    List<VkStaticPin> pins = const <VkStaticPin>[],
  }) {
    _checkSize(width, height);
    _checkScale(scale);
    return _client.buildUri('staticmap/png', <String, String?>{
      'bbox':
          '${southwest.latitude},${southwest.longitude},'
          '${northeast.latitude},${northeast.longitude}',
      'width': '$width',
      'height': '$height',
      'style': ?style,
      if (scale != null) 'scale': '$scale',
      if (padding != null) 'padding': '$padding',
      if (pins.isNotEmpty)
        'pins': pins.map((VkStaticPin p) => p.toQueryValue()).join('|'),
    });
  }

  void _checkSize(int width, int height) {
    if (width < 32 || width > 1024 || height < 32 || height > 1024) {
      throw ArgumentError(
        'Размер изображения — от 32 до 1024 пикселей, передано '
        '${width}x$height',
      );
    }
  }

  void _checkZoom(int zoom) {
    if (zoom < 0 || zoom > 17) {
      throw ArgumentError.value(zoom, 'zoom', 'Допустимы значения от 0 до 17');
    }
  }

  void _checkScale(int? scale) {
    if (scale != null && scale != 1 && scale != 2) {
      throw ArgumentError.value(scale, 'scale', 'Допустимы значения 1 или 2');
    }
  }
}
