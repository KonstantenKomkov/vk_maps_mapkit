import 'package:meta/meta.dart';

import 'camera.dart';
import 'edge_insets.dart';
import 'map_style.dart';

/// Угол карты, в котором показывается логотип VK.
///
/// Скрыть логотип нельзя: в нативных SDK такой возможности нет, и атрибуция
/// обязательна — см. `docs/design-decisions.md`, решение Р-7.
enum VkLogoAlignment {
  /// Левый верхний угол.
  topLeft,

  /// Правый верхний угол.
  topRight,

  /// Левый нижний угол.
  bottomLeft,

  /// Правый нижний угол.
  bottomRight,
}

/// Как карта реагирует на касание объектов стиля.
///
/// Повторяет `FeaturesSelectionMode` нативного SDK.
enum VkFeaturesSelectionMode {
  /// Не реагировать.
  none,

  /// Присылать события выбора, но не подсвечивать объект.
  handleEvents,

  /// Подсвечивать выбранный объект, событий не присылать.
  drawSelection,

  /// Подсвечивать и присылать события.
  all,
}

/// Способ встраивания нативной карты в дерево Flutter на Android.
///
/// Выбор режима отдан приложению: у каждого режима свой компромисс между
/// производительностью и корректностью наложения Flutter-виджетов поверх
/// карты.
enum VkPlatformViewType {
  /// Гибридная композиция.
  hybrid,

  /// Виртуальные дисплеи.
  virtual,

  /// Гибридная композиция через текстуру.
  textureHybrid,

  /// Режим по умолчанию: Flutter выбирает подходящий сам.
  compat,
}

/// Настройки карты, которые можно менять после её создания.
///
/// Все поля необязательные: объект используется и как полный набор настроек,
/// и как дельта между двумя состояниями виджета.
@immutable
class VkMapConfiguration {
  /// Создаёт набор настроек.
  const VkMapConfiguration({
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

  /// Стиль карты.
  final VkMapStyle? style;

  /// Показывать ли компас.
  final bool? compassEnabled;

  /// Показывать ли кнопки масштабирования.
  final bool? zoomButtonsEnabled;

  /// Показывать ли кнопку «текущая позиция».
  final bool? currentLocationButtonEnabled;

  /// Разрешено ли двигать карту жестами.
  final bool? scrollGesturesEnabled;

  /// Разрешено ли масштабировать жестами.
  final bool? zoomGesturesEnabled;

  /// Разрешено ли вращать жестами.
  final bool? rotateGesturesEnabled;

  /// В каком углу показывать логотип VK.
  final VkLogoAlignment? logoAlignment;

  /// Отступы логотипа от края карты.
  final VkEdgeInsets? logoInsets;

  /// Игнорировать ли безопасную область при размещении логотипа.
  final bool? logoIgnoresSafeArea;

  /// Отступы камеры.
  final VkEdgeInsets? padding;

  /// Как реагировать на касание объектов стиля.
  final VkFeaturesSelectionMode? featuresSelectionMode;

  /// Минимальный уровень масштабирования.
  final double? minZoom;

  /// Максимальный уровень масштабирования.
  final double? maxZoom;

  /// Нет ли в наборе ни одной заданной настройки.
  bool get isEmpty =>
      style == null &&
      compassEnabled == null &&
      zoomButtonsEnabled == null &&
      currentLocationButtonEnabled == null &&
      scrollGesturesEnabled == null &&
      zoomGesturesEnabled == null &&
      rotateGesturesEnabled == null &&
      logoAlignment == null &&
      logoInsets == null &&
      logoIgnoresSafeArea == null &&
      padding == null &&
      featuresSelectionMode == null &&
      minZoom == null &&
      maxZoom == null;

  /// Есть ли в наборе хоть одна заданная настройка.
  bool get isNotEmpty => !isEmpty;

  /// Возвращает только те настройки, которые отличаются от [previous].
  ///
  /// Пустой результат означает, что в натив идти не нужно.
  VkMapConfiguration diffFrom(VkMapConfiguration previous) =>
      VkMapConfiguration(
        style: style != previous.style ? style : null,
        compassEnabled: compassEnabled != previous.compassEnabled
            ? compassEnabled
            : null,
        zoomButtonsEnabled: zoomButtonsEnabled != previous.zoomButtonsEnabled
            ? zoomButtonsEnabled
            : null,
        currentLocationButtonEnabled:
            currentLocationButtonEnabled !=
                previous.currentLocationButtonEnabled
            ? currentLocationButtonEnabled
            : null,
        scrollGesturesEnabled:
            scrollGesturesEnabled != previous.scrollGesturesEnabled
            ? scrollGesturesEnabled
            : null,
        zoomGesturesEnabled: zoomGesturesEnabled != previous.zoomGesturesEnabled
            ? zoomGesturesEnabled
            : null,
        rotateGesturesEnabled:
            rotateGesturesEnabled != previous.rotateGesturesEnabled
            ? rotateGesturesEnabled
            : null,
        logoAlignment: logoAlignment != previous.logoAlignment
            ? logoAlignment
            : null,
        logoInsets: logoInsets != previous.logoInsets ? logoInsets : null,
        logoIgnoresSafeArea: logoIgnoresSafeArea != previous.logoIgnoresSafeArea
            ? logoIgnoresSafeArea
            : null,
        padding: padding != previous.padding ? padding : null,
        featuresSelectionMode:
            featuresSelectionMode != previous.featuresSelectionMode
            ? featuresSelectionMode
            : null,
        minZoom: minZoom != previous.minZoom ? minZoom : null,
        maxZoom: maxZoom != previous.maxZoom ? maxZoom : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkMapConfiguration &&
          other.style == style &&
          other.compassEnabled == compassEnabled &&
          other.zoomButtonsEnabled == zoomButtonsEnabled &&
          other.currentLocationButtonEnabled == currentLocationButtonEnabled &&
          other.scrollGesturesEnabled == scrollGesturesEnabled &&
          other.zoomGesturesEnabled == zoomGesturesEnabled &&
          other.rotateGesturesEnabled == rotateGesturesEnabled &&
          other.logoAlignment == logoAlignment &&
          other.logoInsets == logoInsets &&
          other.logoIgnoresSafeArea == logoIgnoresSafeArea &&
          other.padding == padding &&
          other.featuresSelectionMode == featuresSelectionMode &&
          other.minZoom == minZoom &&
          other.maxZoom == maxZoom;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    style,
    compassEnabled,
    zoomButtonsEnabled,
    currentLocationButtonEnabled,
    scrollGesturesEnabled,
    zoomGesturesEnabled,
    rotateGesturesEnabled,
    logoAlignment,
    logoInsets,
    logoIgnoresSafeArea,
    padding,
    featuresSelectionMode,
    minZoom,
    maxZoom,
  ]);

  @override
  String toString() => 'VkMapConfiguration(style: $style, ...)';
}

/// Начальные параметры карты, которые задаются один раз при создании.
@immutable
class VkMapInitialConfiguration {
  /// Создаёт начальные параметры.
  const VkMapInitialConfiguration({
    required this.initialCameraPosition,
    this.configuration = const VkMapConfiguration(),
    this.platformViewType = VkPlatformViewType.compat,
  });

  /// Положение камеры при первом показе карты.
  final VkCameraPosition initialCameraPosition;

  /// Остальные настройки карты.
  final VkMapConfiguration configuration;

  /// Способ встраивания нативной карты (учитывается только на Android).
  final VkPlatformViewType platformViewType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkMapInitialConfiguration &&
          other.initialCameraPosition == initialCameraPosition &&
          other.configuration == configuration &&
          other.platformViewType == platformViewType;

  @override
  int get hashCode =>
      Object.hash(initialCameraPosition, configuration, platformViewType);

  @override
  String toString() =>
      'VkMapInitialConfiguration($initialCameraPosition, $platformViewType)';
}
