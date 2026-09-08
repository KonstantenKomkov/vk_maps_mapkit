// Контракт моста Dart ↔ native. Один на обе платформы (решение Р-2).
//
// После правки выполнить `make gen` в корне репозитория: сгенерированные
// файлы коммитятся вместе с этим.
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartPackageName: 'vk_maps_mapkit_platform_interface',
    // ignore: lines_longer_than_80_chars
    kotlinOut:
        '../vk_maps_mapkit_android/android/src/main/kotlin/com/vk/maps/vk_maps_mapkit_android/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.vk.maps.vk_maps_mapkit_android'),
    // ignore: lines_longer_than_80_chars
    swiftOut:
        '../vk_maps_mapkit_ios/ios/vk_maps_mapkit_ios/Sources/vk_maps_mapkit_ios/Messages.g.swift',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Готовый стиль из состава SDK.
enum PlatformPredefinedStyle {
  main,
  dark,
  grayLight,
  simple,
  simpleDark,
  navigationMain,
  navigationDark,
}

/// Каким способом задан стиль карты.
enum PlatformStyleKind { predefined, json, url }

/// Режим следования карты за индикатором пользователя.
enum PlatformMapMode { free, followLocation, followBearingAndLocation }

/// Угол, в котором показывается логотип VK.
enum PlatformLogoAlignment { topLeft, topRight, bottomLeft, bottomRight }

/// Точка картинки маркера, стоящая на координате.
enum PlatformMarkerAlignment {
  center,
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Кривая ускорения анимации камеры.
enum PlatformAnimationEasing { linear, easeIn, easeOut, easeInOut }

/// Трактовка длительности анимации.
enum PlatformAnimationDurationMode { exact, atMost }

/// Как карта реагирует на касание объектов стиля.
enum PlatformFeaturesSelectionMode { none, handleEvents, drawSelection, all }

/// Способ встраивания нативной карты (учитывается только на Android).
enum PlatformViewType { hybrid, virtual, textureHybrid, compat }

/// Чем закончилось перемещение камеры.
enum PlatformCameraAnimationResult { finished, cancelled }

/// Причина перемещения камеры.
enum PlatformCameraMovingReason { gesture, api, followMode, unknown }

/// Фаза перемещения камеры.
enum PlatformCameraMovingPhase {
  started,
  moving,
  singleCompleted,
  allCompleted,
  cancelled,
}

/// Тип события карты.
enum PlatformMapEventType {
  mapShown,
  tap,
  longTap,
  markerTap,
  cameraMove,
  styleApplied,
  modeChanged,
  lowMemory,
  error,
}

class PlatformLatLon {
  PlatformLatLon({required this.latitude, required this.longitude});

  double latitude;
  double longitude;
}

class PlatformLatLonBounds {
  PlatformLatLonBounds({required this.southwest, required this.northeast});

  PlatformLatLon southwest;
  PlatformLatLon northeast;
}

class PlatformScreenPoint {
  PlatformScreenPoint({required this.x, required this.y});

  double x;
  double y;
}

class PlatformEdgeInsets {
  PlatformEdgeInsets({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  double left;
  double top;
  double right;
  double bottom;
}

class PlatformCameraPosition {
  PlatformCameraPosition({
    required this.target,
    required this.zoom,
    required this.bearing,
    required this.pitch,
  });

  PlatformLatLon target;
  double zoom;
  double bearing;
  double pitch;
}

class PlatformCameraOptions {
  PlatformCameraOptions({this.zoom, this.bearing, this.pitch, this.padding});

  double? zoom;
  double? bearing;
  double? pitch;
  PlatformEdgeInsets? padding;
}

class PlatformAnimationOptions {
  PlatformAnimationOptions({
    required this.durationMillis,
    required this.easing,
    required this.durationMode,
  });

  int durationMillis;
  PlatformAnimationEasing easing;
  PlatformAnimationDurationMode durationMode;
}

/// Стиль карты: `kind` определяет, что лежит в остальных полях.
class PlatformStyle {
  PlatformStyle({required this.kind, this.predefined, this.json, this.url});

  PlatformStyleKind kind;
  PlatformPredefinedStyle? predefined;
  String? json;
  String? url;
}

/// Настройки карты. Незаданные поля означают «не менять».
class PlatformMapConfiguration {
  PlatformMapConfiguration({
    this.style,
    this.compassEnabled,
    this.zoomButtonsEnabled,
    this.currentLocationButtonEnabled,
    this.scrollGesturesEnabled,
    this.zoomGesturesEnabled,
    this.rotateGesturesEnabled,
    this.logoAlignment,
    this.logoInsets,
    this.logoIgnoresSafeArea,
    this.padding,
    this.featuresSelectionMode,
    this.minZoom,
    this.maxZoom,
  });

  PlatformStyle? style;
  bool? compassEnabled;
  bool? zoomButtonsEnabled;
  bool? currentLocationButtonEnabled;
  bool? scrollGesturesEnabled;
  bool? zoomGesturesEnabled;
  bool? rotateGesturesEnabled;
  PlatformLogoAlignment? logoAlignment;
  PlatformEdgeInsets? logoInsets;
  bool? logoIgnoresSafeArea;
  PlatformEdgeInsets? padding;
  PlatformFeaturesSelectionMode? featuresSelectionMode;
  double? minZoom;
  double? maxZoom;
}

class PlatformMapCreationParams {
  PlatformMapCreationParams({
    required this.initialCameraPosition,
    required this.configuration,
    required this.platformViewType,
  });

  PlatformCameraPosition initialCameraPosition;
  PlatformMapConfiguration configuration;
  PlatformViewType platformViewType;
}

class PlatformMarker {
  PlatformMarker({
    required this.markerId,
    required this.position,
    required this.imageId,
    required this.alignment,
    required this.zIndex,
    required this.visible,
  });

  String markerId;
  PlatformLatLon position;
  String imageId;
  PlatformMarkerAlignment alignment;
  int zIndex;
  bool visible;
}

/// Дельта набора маркеров: только то, что изменилось.
class PlatformMarkerUpdates {
  PlatformMarkerUpdates({
    required this.toAdd,
    required this.toChange,
    required this.idsToRemove,
  });

  List<PlatformMarker> toAdd;
  List<PlatformMarker> toChange;
  List<String> idsToRemove;
}

/// Событие карты. Набор заполненных полей определяется полем `type`.
class PlatformMapEvent {
  PlatformMapEvent({
    required this.type,
    this.position,
    this.screenPoint,
    this.markerId,
    this.cameraPosition,
    this.cameraMovingReason,
    this.cameraMovingPhase,
    this.mode,
    this.errorCode,
    this.errorMessage,
  });

  PlatformMapEventType type;
  PlatformLatLon? position;
  PlatformScreenPoint? screenPoint;
  String? markerId;
  PlatformCameraPosition? cameraPosition;
  PlatformCameraMovingReason? cameraMovingReason;
  PlatformCameraMovingPhase? cameraMovingPhase;
  PlatformMapMode? mode;
  String? errorCode;
  String? errorMessage;
}

/// Разовая настройка SDK на процесс: ключ доступа и параметры сети.
@HostApi()
abstract class VkMapsInitializerApi {
  /// Настраивает SDK. Повторный вызов с теми же параметрами ничего не делает.
  @async
  bool setup(String apiKey, String? baseUrl, String? locale);

  /// Настроен ли SDK.
  bool isInitialized();
}

/// Управление конкретной картой. Первый аргумент — идентификатор
/// platform view, потому что карт в приложении может быть несколько.
@HostApi()
abstract class VkMapsHostApi {
  /// Создаёт карту внутри уже размещённого нативного представления.
  ///
  /// Вызывается один раз сразу после появления platform view: параметры
  /// создания идут этим вызовом, а не через кодек представления, чтобы
  /// контракт оставался один на всё.
  @async
  void initializeView(int viewId, PlatformMapCreationParams params);

  /// Применяет настройки карты. Передавать только изменившиеся поля.
  void updateConfiguration(int viewId, PlatformMapConfiguration configuration);

  /// Применяет дельту набора маркеров.
  void updateMarkers(int viewId, PlatformMarkerUpdates updates);

  /// Перемещает камеру. Пустые `animation` означают мгновенное перемещение.
  @async
  PlatformCameraAnimationResult moveCamera(
    int viewId,
    PlatformLatLon? target,
    PlatformCameraOptions? options,
    PlatformAnimationOptions? animation,
  );

  /// Вписывает область в карту.
  @async
  PlatformCameraAnimationResult fitBounds(
    int viewId,
    PlatformLatLonBounds bounds,
    PlatformEdgeInsets padding,
    PlatformAnimationOptions? animation,
  );

  /// Текущее положение камеры.
  PlatformCameraPosition getCameraPosition(int viewId);

  /// Границы видимой области.
  PlatformLatLonBounds getVisibleBounds(int viewId);

  /// Координата по точке на экране.
  PlatformLatLon? coordinateForScreenPoint(
    int viewId,
    PlatformScreenPoint point,
  );

  /// Точка на экране по координате.
  PlatformScreenPoint? screenPointForCoordinate(
    int viewId,
    PlatformLatLon coordinate,
  );

  /// Текущий режим следования.
  PlatformMapMode getMode(int viewId);

  /// Устанавливает режим следования.
  void setMode(int viewId, PlatformMapMode mode);

  /// Задаёт положение индикатора пользователя.
  void setUserLocation(
    int viewId,
    PlatformLatLon? coordinates,
    double? bearing,
    double? accuracy,
    bool visible,
  );

  /// Добавляет изображение в стиль карты, чтобы на него могли ссылаться
  /// маркеры.
  @async
  void addStyleImage(
    int viewId,
    String imageId,
    Uint8List pngBytes,
    double scale,
  );

  /// Убирает изображение из стиля.
  void removeStyleImage(int viewId, String imageId);

  /// Добавляет в стиль источник данных GeoJSON.
  @async
  void addGeoJsonSource(int viewId, String sourceId, String geoJson);

  /// Заменяет данные источника GeoJSON.
  void setGeoJsonSourceData(int viewId, String sourceId, String geoJson);

  /// Добавляет источник из закодированной ломаной маршрута.
  @async
  void addEncodedPolylineSource(int viewId, String sourceId, String polyline);

  /// Убирает источник из стиля.
  void removeSource(int viewId, String sourceId);

  /// Добавляет слой, описанный JSON по спецификации Mapbox Style.
  @async
  void addLayer(int viewId, String layerJson, String? beforeLayerId);

  /// Убирает слой из стиля.
  void removeLayer(int viewId, String layerId);

  /// Показывает или скрывает слой.
  void setLayerVisibility(int viewId, String layerId, bool visible);

  /// Освобождает ресурсы карты.
  void dispose(int viewId);
}

/// События карты, которые натив шлёт во Flutter.
@FlutterApi()
abstract class VkMapsFlutterApi {
  /// Событие карты [viewId].
  void onEvent(int viewId, PlatformMapEvent event);
}
