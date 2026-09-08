import 'package:meta/meta.dart';

/// Готовый стиль карты из состава SDK.
///
/// Значения повторяют `MapPredefinedStyle` нативного SDK.
enum VkPredefinedStyle {
  /// Основной дневной стиль.
  main,

  /// Тёмный стиль.
  dark,

  /// Светло-серый стиль.
  grayLight,

  /// Упрощённый стиль.
  simple,

  /// Упрощённый тёмный стиль.
  simpleDark,

  /// Навигационный дневной стиль.
  navigationMain,

  /// Навигационный тёмный стиль.
  navigationDark,
}

/// Стиль карты: готовый из SDK, JSON по спецификации Mapbox Style либо ссылка
/// на такой JSON.
@immutable
sealed class VkMapStyle {
  const VkMapStyle();

  /// Готовый стиль из состава SDK.
  const factory VkMapStyle.predefined(VkPredefinedStyle style) =
      VkPredefinedMapStyle;

  /// Стиль из строки JSON.
  const factory VkMapStyle.json(String json) = VkJsonMapStyle;

  /// Стиль, загружаемый по ссылке.
  const factory VkMapStyle.url(Uri url) = VkUrlMapStyle;
}

/// Стиль из состава SDK.
@immutable
final class VkPredefinedMapStyle extends VkMapStyle {
  /// Создаёт ссылку на готовый стиль.
  const VkPredefinedMapStyle(this.style);

  /// Какой именно готовый стиль.
  final VkPredefinedStyle style;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkPredefinedMapStyle && other.style == style;

  @override
  int get hashCode => style.hashCode;

  @override
  String toString() => 'VkMapStyle.predefined(${style.name})';
}

/// Стиль, заданный строкой JSON.
@immutable
final class VkJsonMapStyle extends VkMapStyle {
  /// Создаёт стиль из JSON.
  const VkJsonMapStyle(this.json);

  /// Тело стиля по спецификации Mapbox Style.
  final String json;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VkJsonMapStyle && other.json == json;

  @override
  int get hashCode => json.hashCode;

  @override
  String toString() => 'VkMapStyle.json(${json.length} символов)';
}

/// Стиль, загружаемый по ссылке.
@immutable
final class VkUrlMapStyle extends VkMapStyle {
  /// Создаёт стиль по ссылке.
  const VkUrlMapStyle(this.url);

  /// Ссылка на JSON стиля.
  final Uri url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VkUrlMapStyle && other.url == url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'VkMapStyle.url($url)';
}
