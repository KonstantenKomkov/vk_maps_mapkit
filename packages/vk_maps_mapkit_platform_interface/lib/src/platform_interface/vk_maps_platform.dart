import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../events/map_event.dart';
import '../pigeon/pigeon_vk_maps_platform.dart';
import '../types/types.dart';

/// Контракт, который реализуют платформенные пакеты плагина.
///
/// Приложения обращаются к нему не напрямую, а через фасад `vk_maps_mapkit`.
/// Тесты подменяют реализацию через [VkMapsPlatform.instance].
abstract base class VkMapsPlatform extends PlatformInterface {
  /// Базовый конструктор для наследников.
  VkMapsPlatform() : super(token: _token);

  static final Object _token = Object();

  static VkMapsPlatform _instance = PigeonVkMapsPlatform();

  /// Текущая реализация платформы.
  static VkMapsPlatform get instance => _instance;

  /// Устанавливает реализацию платформы.
  ///
  /// Платформенные пакеты вызывают это в своём `registerWith`, тесты —
  /// чтобы подставить фейк.
  static set instance(VkMapsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Настраивает SDK: ключ доступа, базовый адрес и язык подписей.
  ///
  /// Повторный вызов не переинициализирует SDK.
  Future<void> initialize({
    required String apiKey,
    String? baseUrl,
    String? locale,
  });

  /// Настроен ли SDK.
  Future<bool> isInitialized();

  /// Создаёт карту внутри уже размещённого нативного представления.
  ///
  /// Вызывается платформенным пакетом сразу после появления представления:
  /// параметры создания идут типизированным вызовом, а не через кодек
  /// platform view.
  Future<void> initializeView(
    int viewId,
    VkMapInitialConfiguration configuration,
  );

  /// Применяет настройки карты. Пустая дельта в натив не уходит.
  Future<void> updateConfiguration(
    int viewId,
    VkMapConfiguration configuration,
  );

  /// Применяет дельту набора маркеров. Пустая дельта в натив не уходит.
  Future<void> updateMarkers(int viewId, VkMarkerUpdates updates);

  /// Перемещает камеру.
  Future<VkCameraAnimationResult> moveCamera(
    int viewId, {
    VkLatLon? target,
    VkCameraOptions? options,
    VkAnimationOptions? animation,
  });

  /// Вписывает область в видимую часть карты.
  Future<VkCameraAnimationResult> fitBounds(
    int viewId,
    VkLatLonBounds bounds, {
    VkEdgeInsets padding = VkEdgeInsets.zero,
    VkAnimationOptions? animation,
  });

  /// Текущее положение камеры.
  Future<VkCameraPosition> getCameraPosition(int viewId);

  /// Границы видимой области карты.
  Future<VkLatLonBounds> getVisibleBounds(int viewId);

  /// Координата по точке на экране, если точка попадает в карту.
  Future<VkLatLon?> coordinateForScreenPoint(int viewId, VkScreenPoint point);

  /// Точка на экране по координате, если она видна.
  Future<VkScreenPoint?> screenPointForCoordinate(
    int viewId,
    VkLatLon coordinate,
  );

  /// Текущий режим следования.
  Future<VkMapMode> getMode(int viewId);

  /// Устанавливает режим следования.
  Future<void> setMode(int viewId, VkMapMode mode);

  /// Задаёт положение индикатора пользователя.
  ///
  /// Плагин не запрашивает геолокацию сам: координаты приходят от
  /// приложения, которое само решает вопрос с разрешениями.
  Future<void> setUserLocation(
    int viewId, {
    VkLatLon? coordinates,
    double? bearing,
    double? accuracy,
    bool visible = true,
  });

  /// Добавляет изображение в стиль карты: на него ссылаются маркеры.
  Future<void> addStyleImage(
    int viewId,
    String imageId,
    Uint8List pngBytes, {
    double scale = 1.0,
  });

  /// Убирает изображение из стиля карты.
  Future<void> removeStyleImage(int viewId, String imageId);

  /// Добавляет в стиль источник данных GeoJSON.
  Future<void> addGeoJsonSource(int viewId, String sourceId, String geoJson);

  /// Заменяет данные источника GeoJSON.
  Future<void> setGeoJsonSourceData(
    int viewId,
    String sourceId,
    String geoJson,
  );

  /// Добавляет источник из закодированной ломаной маршрута.
  Future<void> addEncodedPolylineSource(
    int viewId,
    String sourceId,
    String polyline,
  );

  /// Убирает источник из стиля.
  Future<void> removeSource(int viewId, String sourceId);

  /// Добавляет слой, описанный по спецификации Mapbox Style.
  ///
  /// [beforeLayerId] позволяет вставить слой под уже существующий.
  Future<void> addLayer(
    int viewId,
    VkStyleLayer layer, {
    String? beforeLayerId,
  });

  /// Убирает слой из стиля.
  Future<void> removeLayer(int viewId, String layerId);

  /// Показывает или скрывает слой.
  Future<void> setLayerVisibility(int viewId, String layerId, bool visible);

  /// Освобождает ресурсы карты.
  Future<void> dispose(int viewId);

  /// Поток событий карты [viewId].
  Stream<VkMapEvent> events(int viewId);

  /// Строит нативное представление карты.
  ///
  /// Реализуется платформенными пакетами: `AndroidView` на Android,
  /// `UiKitView` на iOS.
  Widget buildView({
    required VkMapInitialConfiguration configuration,
    required void Function(int viewId) onPlatformViewCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers =
        const <Factory<OneSequenceGestureRecognizer>>{},
    PlatformViewHitTestBehavior hitTestBehavior =
        PlatformViewHitTestBehavior.opaque,
    TextDirection? layoutDirection,
  }) {
    throw UnimplementedError(
      'buildView не реализован на этой платформе. VK Карты доступны на '
      'Android и iOS; для ${defaultTargetPlatform.name} реализации нет.',
    );
  }
}
