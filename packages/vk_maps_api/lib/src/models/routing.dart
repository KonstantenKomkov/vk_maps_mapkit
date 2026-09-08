import 'package:meta/meta.dart';

import '../polyline.dart';
import 'geo_point.dart';

/// Тип транспорта для расчёта маршрута.
enum VkCosting {
  /// Автомобиль.
  auto,

  /// Грузовой транспорт.
  truck,

  /// Пешком.
  pedestrian,

  /// Велосипед.
  bicycle,

  /// Такси и транспорт с доступом к выделенным полосам.
  taxi,
}

/// Единицы измерения расстояния в ответе.
enum VkDistanceUnits {
  /// Километры.
  kilometers,

  /// Мили.
  miles;

  /// Значение параметра `units`.
  String get value =>
      this == VkDistanceUnits.kilometers ? 'kilometers' : 'miles';
}

/// Роль точки в маршруте.
enum VkLocationType {
  /// Остановка: маршрут разбивается на участки по таким точкам.
  breakPoint,

  /// Промежуточная точка без остановки.
  via;

  /// Значение поля `type`.
  String get value => this == VkLocationType.breakPoint ? 'break' : 'via';
}

/// Точка маршрута в запросе.
@immutable
class VkRouteLocation {
  /// Создаёт точку маршрута.
  const VkRouteLocation(this.point, {this.type, this.heading});

  /// Координата точки.
  final VkGeoPoint point;

  /// Роль точки: остановка или проездная.
  final VkLocationType? type;

  /// Желаемое направление движения в начале, в градусах от севера.
  final double? heading;

  /// Тело точки для запроса.
  Map<String, dynamic> toJson() => <String, dynamic>{
    ...point.toJson(),
    if (type != null) 'type': type!.value,
    'heading': ?heading,
  };
}

/// Общая информация об участке или маршруте.
@immutable
class VkRouteSummary {
  /// Создаёт сводку.
  const VkRouteSummary({
    required this.time,
    required this.length,
    this.boundingBox,
  });

  /// Разбирает объект `summary`.
  ///
  /// Границы приходят двумя способами: полями `min_lat`…`max_lon` прямо в
  /// сводке либо списком `ll_boxes` (в нём два элемента, если маршрут
  /// пересекает антимеридиан, — берётся первый).
  factory VkRouteSummary.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> box = json;
    final Object? boxes = json['ll_boxes'];
    if (boxes is List<dynamic> &&
        boxes.isNotEmpty &&
        boxes.first is Map<String, dynamic>) {
      box = boxes.first as Map<String, dynamic>;
    }
    final double? minLat = (box['min_lat'] as num?)?.toDouble();
    final double? minLon = (box['min_lon'] as num?)?.toDouble();
    final double? maxLat = (box['max_lat'] as num?)?.toDouble();
    final double? maxLon = (box['max_lon'] as num?)?.toDouble();
    return VkRouteSummary(
      time: Duration(
        milliseconds: (((json['time'] as num?)?.toDouble() ?? 0) * 1000)
            .round(),
      ),
      length: (json['length'] as num?)?.toDouble() ?? 0,
      boundingBox:
          minLat != null && minLon != null && maxLat != null && maxLon != null
          ? VkBoundingBox(
              southwest: VkGeoPoint(minLat, minLon),
              northeast: VkGeoPoint(maxLat, maxLon),
            )
          : null,
    );
  }

  /// Расчётное время в пути.
  final Duration time;

  /// Длина в выбранных единицах измерения.
  final double length;

  /// Область, которую занимает маршрут.
  final VkBoundingBox? boundingBox;

  @override
  String toString() => 'VkRouteSummary($length, $time)';
}

/// Манёвр на участке маршрута.
@immutable
class VkManeuver {
  /// Создаёт манёвр.
  const VkManeuver({
    required this.instruction,
    required this.time,
    required this.length,
    this.streetNames = const <String>[],
    this.beginShapeIndex,
    this.endShapeIndex,
    this.raw = const <String, dynamic>{},
  });

  /// Разбирает объект манёвра.
  factory VkManeuver.fromJson(Map<String, dynamic> json) => VkManeuver(
    instruction: json['instruction'] as String? ?? '',
    time: Duration(
      milliseconds: (((json['time'] as num?)?.toDouble() ?? 0) * 1000).round(),
    ),
    length: (json['length'] as num?)?.toDouble() ?? 0,
    streetNames:
        (json['street_names'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[],
    beginShapeIndex: (json['begin_shape_index'] as num?)?.toInt(),
    endShapeIndex: (json['end_shape_index'] as num?)?.toInt(),
    raw: json,
  );

  /// Текстовая инструкция.
  final String instruction;

  /// Время манёвра.
  final Duration time;

  /// Длина манёвра.
  final double length;

  /// Названия улиц.
  final List<String> streetNames;

  /// Индекс начала манёвра в геометрии участка.
  final int? beginShapeIndex;

  /// Индекс конца манёвра в геометрии участка.
  final int? endShapeIndex;

  /// Исходный JSON манёвра.
  final Map<String, dynamic> raw;

  @override
  String toString() => 'VkManeuver($instruction)';
}

/// Участок маршрута между двумя точками-остановками.
@immutable
class VkRouteLeg {
  /// Создаёт участок.
  const VkRouteLeg({
    required this.summary,
    required this.shape,
    this.encodedShape = '',
    this.maneuvers = const <VkManeuver>[],
  });

  /// Разбирает объект `legs[]`.
  factory VkRouteLeg.fromJson(Map<String, dynamic> json) => VkRouteLeg(
    summary: VkRouteSummary.fromJson(
      json['summary'] as Map<String, dynamic>? ?? const <String, dynamic>{},
    ),
    shape: json['shape'] is String
        ? VkPolyline.decode(json['shape'] as String)
        : const <VkGeoPoint>[],
    encodedShape: json['shape'] as String? ?? '',
    maneuvers:
        (json['maneuvers'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(VkManeuver.fromJson)
            .toList() ??
        const <VkManeuver>[],
  );

  /// Сводка по участку.
  final VkRouteSummary summary;

  /// Геометрия участка: ломаная уже раскодирована.
  final List<VkGeoPoint> shape;

  /// Та же геометрия в исходном виде — закодированной строкой.
  ///
  /// В этом виде её принимает карта: `controller.drawRoute(encodedShape)`
  /// не требует раскодирования и обратной сборки GeoJSON.
  final String encodedShape;

  /// Манёвры участка, если они запрошены.
  final List<VkManeuver> maneuvers;

  @override
  String toString() => 'VkRouteLeg(точек: ${shape.length})';
}

/// Маршрут целиком.
@immutable
class VkRoute {
  /// Создаёт маршрут.
  const VkRoute({
    required this.summary,
    required this.legs,
    this.locations = const <VkGeoPoint>[],
    this.language,
    this.units,
    this.statusMessage,
    this.raw = const <String, dynamic>{},
  });

  /// Разбирает объект `trip`.
  factory VkRoute.fromTripJson(Map<String, dynamic> json) => VkRoute(
    summary: VkRouteSummary.fromJson(
      json['summary'] as Map<String, dynamic>? ?? const <String, dynamic>{},
    ),
    legs:
        (json['legs'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(VkRouteLeg.fromJson)
            .toList() ??
        const <VkRouteLeg>[],
    locations:
        (json['locations'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(VkGeoPoint.fromJson)
            .toList() ??
        const <VkGeoPoint>[],
    language: json['language'] as String?,
    units: json['units'] as String?,
    statusMessage: json['status_message'] as String?,
    raw: json,
  );

  /// Сводка по всему маршруту.
  final VkRouteSummary summary;

  /// Участки маршрута.
  final List<VkRouteLeg> legs;

  /// Точки маршрута, как их вернул сервис.
  final List<VkGeoPoint> locations;

  /// Язык инструкций.
  final String? language;

  /// Единицы измерения расстояния.
  final String? units;

  /// Сообщение сервиса о результате.
  final String? statusMessage;

  /// Исходный JSON маршрута.
  final Map<String, dynamic> raw;

  /// Геометрия всего маршрута: участки, склеенные подряд.
  List<VkGeoPoint> get shape => <VkGeoPoint>[
    for (final VkRouteLeg leg in legs) ...leg.shape,
  ];

  @override
  String toString() =>
      'VkRoute(${summary.length}, ${summary.time}, участков: ${legs.length})';
}

/// Ответ сервисов маршрутизации: основной маршрут и альтернативы.
@immutable
class VkRoutesResponse {
  /// Создаёт ответ.
  const VkRoutesResponse({required this.routes, this.id});

  /// Разбирает ответ `/directions` и `/optimal_route`.
  factory VkRoutesResponse.fromJson(Map<String, dynamic> json) {
    final List<VkRoute> routes = <VkRoute>[];
    final Object? trips = json['trips'];
    if (trips is List<dynamic>) {
      for (final Object? item in trips) {
        if (item is Map<String, dynamic> &&
            item['trip'] is Map<String, dynamic>) {
          routes.add(
            VkRoute.fromTripJson(item['trip'] as Map<String, dynamic>),
          );
        }
      }
    }
    if (routes.isEmpty && json['trip'] is Map<String, dynamic>) {
      routes.add(VkRoute.fromTripJson(json['trip'] as Map<String, dynamic>));
    }
    return VkRoutesResponse(
      routes: List<VkRoute>.unmodifiable(routes),
      id: json['id'] as String?,
    );
  }

  /// Маршруты: первый — основной, остальные — альтернативы.
  final List<VkRoute> routes;

  /// Идентификатор запроса, если он был задан.
  final String? id;

  /// Основной маршрут или `null`, если сервис ничего не построил.
  VkRoute? get primary => routes.isEmpty ? null : routes.first;

  @override
  String toString() => 'VkRoutesResponse(маршрутов: ${routes.length})';
}

/// Ячейка матрицы достижимости.
@immutable
class VkMatrixCell {
  /// Создаёт ячейку.
  const VkMatrixCell({
    required this.fromIndex,
    required this.toIndex,
    required this.distance,
    required this.time,
  });

  /// Разбирает элемент `sources_to_targets`.
  factory VkMatrixCell.fromJson(Map<String, dynamic> json) => VkMatrixCell(
    fromIndex: (json['from_index'] as num?)?.toInt() ?? 0,
    toIndex: (json['to_index'] as num?)?.toInt() ?? 0,
    distance: (json['distance'] as num?)?.toDouble(),
    time: json['time'] == null
        ? null
        : Duration(
            milliseconds: (((json['time'] as num).toDouble()) * 1000).round(),
          ),
  );

  /// Индекс точки отправления.
  final int fromIndex;

  /// Индекс точки назначения.
  final int toIndex;

  /// Расстояние в выбранных единицах; `null`, если пути нет.
  final double? distance;

  /// Время в пути; `null`, если пути нет.
  final Duration? time;

  @override
  String toString() => 'VkMatrixCell($fromIndex→$toIndex, $distance, $time)';
}

/// Матрица достижимости.
@immutable
class VkDistanceMatrix {
  /// Создаёт матрицу.
  const VkDistanceMatrix({required this.rows, this.id});

  /// Разбирает ответ `/dm`.
  factory VkDistanceMatrix.fromJson(Map<String, dynamic> json) {
    final List<List<VkMatrixCell>> rows = <List<VkMatrixCell>>[];
    final Object? sourcesToTargets = json['sources_to_targets'];
    if (sourcesToTargets is List<dynamic>) {
      for (final Object? row in sourcesToTargets) {
        if (row is List<dynamic>) {
          rows.add(
            List<VkMatrixCell>.unmodifiable(
              row.whereType<Map<String, dynamic>>().map(VkMatrixCell.fromJson),
            ),
          );
        }
      }
    }
    return VkDistanceMatrix(
      rows: List<List<VkMatrixCell>>.unmodifiable(rows),
      id: json['id'] as String?,
    );
  }

  /// Строки матрицы: по одной на точку отправления.
  final List<List<VkMatrixCell>> rows;

  /// Идентификатор запроса.
  final String? id;

  /// Ячейка для пары индексов или `null`, если её нет в ответе.
  VkMatrixCell? cell(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= rows.length) {
      return null;
    }
    for (final VkMatrixCell cell in rows[fromIndex]) {
      if (cell.toIndex == toIndex) {
        return cell;
      }
    }
    return null;
  }

  @override
  String toString() => 'VkDistanceMatrix(${rows.length} строк)';
}

/// Контур области достижимости.
@immutable
class VkIsochroneContour {
  /// Создаёт контур.
  const VkIsochroneContour({
    required this.points,
    this.contour,
    this.color,
    this.metric,
  });

  /// Точки контура.
  final List<VkGeoPoint> points;

  /// Значение контура: минуты для времени, километры для расстояния.
  final double? contour;

  /// Цвет контура из запроса.
  final String? color;

  /// Метрика контура: `time` или `distance`.
  final String? metric;

  @override
  String toString() =>
      'VkIsochroneContour($metric $contour, точек: ${points.length})';
}

/// Ответ сервиса изохрон — GeoJSON с набором контуров.
@immutable
class VkIsochrones {
  /// Создаёт ответ.
  const VkIsochrones({required this.contours, this.id, this.raw = const {}});

  /// Разбирает GeoJSON-ответ `/iso`.
  factory VkIsochrones.fromJson(Map<String, dynamic> json) {
    final List<VkIsochroneContour> contours = <VkIsochroneContour>[];
    final Object? features = json['features'];
    if (features is List<dynamic>) {
      for (final Object? feature in features) {
        if (feature is! Map<String, dynamic>) {
          continue;
        }
        final Map<String, dynamic> properties =
            feature['properties'] as Map<String, dynamic>? ??
            const <String, dynamic>{};
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

        final Map<String, dynamic> geometry =
            feature['geometry'] as Map<String, dynamic>? ??
            const <String, dynamic>{};
        collect(geometry['coordinates']);
        contours.add(
          VkIsochroneContour(
            points: List<VkGeoPoint>.unmodifiable(points),
            contour: (properties['contour'] as num?)?.toDouble(),
            color: properties['color'] as String?,
            metric: properties['metric'] as String?,
          ),
        );
      }
    }
    return VkIsochrones(
      contours: List<VkIsochroneContour>.unmodifiable(contours),
      id: json['id'] as String?,
      raw: json,
    );
  }

  /// Контуры достижимости.
  final List<VkIsochroneContour> contours;

  /// Идентификатор запроса.
  final String? id;

  /// Исходный GeoJSON: пригодится, чтобы отдать его карте как источник.
  final Map<String, dynamic> raw;

  @override
  String toString() => 'VkIsochrones(контуров: ${contours.length})';
}
