@JS()
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// Глобальный объект `mmrgl` — точка входа JavaScript SDK VK Карт.
///
/// Обращаться к нему можно только после [isMmrGlLoaded]: до загрузки
/// библиотеки такого имени в документе нет.
@JS('mmrgl')
external MmrGl get mmrgl;

/// Разбор JSON силами браузера.
///
/// Данные для SDK перекладываются через него: так в JavaScript уходят
/// обычные объекты и массивы, а не внутреннее представление объектов Dart.
@JS('JSON.parse')
external JSAny jsonParse(String text);

/// Загружена ли библиотека `MMR GL JS` на страницу.
bool get isMmrGlLoaded => globalContext.has('mmrgl');

/// Корень JavaScript SDK: глобальные настройки и конструкторы.
///
/// В сборке это класс со статическими членами, поэтому `typeof mmrgl` —
/// `function`, а не `object`.
extension type MmrGl._(JSObject _) implements JSObject {
  /// Ключ доступа к сервисам VK Карт.
  external set accessToken(String value);

  /// Ключ доступа к сервисам VK Карт.
  external String? get accessToken;

  /// Адрес, с которого берутся тайлы, стили, спрайты и глифы.
  external set baseApiUrl(String value);

  /// Версия загруженной сборки библиотеки.
  external String get version;

  /// Поддерживает ли браузер отрисовку карты.
  ///
  /// Метод описан в документации, но есть не в каждой сборке (в 0.2.43 его
  /// нет), поэтому вызывать его можно только после [hasSupportedCheck].
  external bool supported();
}

/// Есть ли в загруженной сборке проверка поддержки браузера.
bool get hasSupportedCheck =>
    isMmrGlLoaded && (mmrgl as JSObject).has('supported');

/// Карта `mmrgl.Map`.
@JS('mmrgl.Map')
extension type MmrMap._(JSObject _) implements JSObject {
  /// Создаёт карту по параметрам конструктора.
  external factory MmrMap(JSObject options);

  /// Подписка на событие карты.
  @JS('on')
  external void on(String type, JSFunction listener);

  /// Подписка на событие в пределах слоя [layerId].
  @JS('on')
  external void onLayer(String type, String layerId, JSFunction listener);

  /// Разовая подписка на событие карты.
  @JS('once')
  external void once(String type, JSFunction listener);

  /// Отписка от события карты.
  @JS('off')
  external void off(String type, JSFunction listener);

  /// Уничтожает карту и освобождает её ресурсы.
  external void remove();

  /// Пересчитывает размеры карты по размеру контейнера.
  external void resize();

  /// Мгновенно переносит камеру.
  external void jumpTo(JSObject options, [JSObject eventData]);

  /// Перемещает камеру с анимацией.
  external void easeTo(JSObject options, [JSObject eventData]);

  /// Вписывает область в видимую часть карты.
  external void fitBounds(JSAny bounds, [JSObject options, JSObject eventData]);

  /// Останавливает текущую анимацию камеры.
  external void stop();

  /// Центр карты.
  external MmrLngLat getCenter();

  /// Уровень масштабирования.
  external double getZoom();

  /// Поворот карты в градусах.
  external double getBearing();

  /// Наклон карты в градусах.
  external double getPitch();

  /// Границы видимой области.
  external MmrLngLatBounds getBounds();

  /// Точка на экране по координате.
  external MmrPoint project(JSAny lngLat);

  /// Координата по точке на экране.
  external MmrLngLat unproject(JSAny point);

  /// Меняет стиль карты.
  external void setStyle(JSAny? style, [JSObject options]);

  /// Загружен ли стиль карты полностью.
  external bool isStyleLoaded();

  /// Добавляет изображение в стиль.
  external void addImage(String id, JSObject image, [JSObject options]);

  /// Есть ли в стиле изображение [id].
  external bool hasImage(String id);

  /// Убирает изображение из стиля.
  external void removeImage(String id);

  /// Добавляет источник данных.
  external void addSource(String id, JSObject source);

  /// Источник по идентификатору.
  external MmrGeoJsonSource? getSource(String id);

  /// Убирает источник данных.
  external void removeSource(String id);

  /// Добавляет слой; [beforeId] вставляет его под существующий слой.
  external void addLayer(JSObject layer, [String? beforeId]);

  /// Слой по идентификатору.
  external JSObject? getLayer(String id);

  /// Убирает слой.
  external void removeLayer(String id);

  /// Задаёт свойство раскладки слоя.
  external void setLayoutProperty(String layerId, String name, JSAny? value);

  /// Задаёт минимальный масштаб.
  external void setMinZoom(double? minZoom);

  /// Задаёт максимальный масштаб.
  external void setMaxZoom(double? maxZoom);

  /// Задаёт отступы камеры.
  external void setPadding(JSObject padding);

  /// Добавляет элемент управления.
  external void addControl(JSObject control, [String position]);

  /// Убирает элемент управления.
  external void removeControl(JSObject control);

  /// Есть ли на карте элемент управления.
  external bool hasControl(JSObject control);

  /// Контейнер карты в документе.
  external web.HTMLElement getContainer();

  /// Видимые объекты слоёв в точке или прямоугольнике [geometry].
  external JSArray<MmrFeature> queryRenderedFeatures(
    JSAny? geometry, [
    JSObject options,
  ]);

  /// Обработчик перетаскивания карты.
  external MmrHandler get dragPan;

  /// Обработчик поворота перетаскиванием.
  external MmrHandler get dragRotate;

  /// Обработчик масштабирования колесом мыши.
  external MmrHandler get scrollZoom;

  /// Обработчик масштабирования и поворота касаниями.
  external MmrHandler get touchZoomRotate;

  /// Обработчик наклона касаниями.
  external MmrHandler get touchPitch;

  /// Обработчик масштабирования двойным щелчком.
  external MmrHandler get doubleClickZoom;

  /// Обработчик управления с клавиатуры.
  external MmrHandler get keyboard;

  /// Обработчик масштабирования рамкой.
  external MmrHandler get boxZoom;
}

/// Обработчик жеста карты: включается и выключается независимо.
extension type MmrHandler._(JSObject _) implements JSObject {
  /// Включает жест.
  external void enable();

  /// Выключает жест.
  external void disable();
}

/// Географическая точка в порядке «долгота, широта».
extension type MmrLngLat._(JSObject _) implements JSObject {
  /// Долгота в градусах.
  external double get lng;

  /// Широта в градусах.
  external double get lat;
}

/// Прямоугольная географическая область.
extension type MmrLngLatBounds._(JSObject _) implements JSObject {
  /// Юго-западный угол.
  external MmrLngLat getSouthWest();

  /// Северо-восточный угол.
  external MmrLngLat getNorthEast();
}

/// Точка на экране в пикселях относительно контейнера карты.
extension type MmrPoint._(JSObject _) implements JSObject {
  /// Координата по горизонтали.
  external double get x;

  /// Координата по вертикали.
  external double get y;
}

/// Источник GeoJSON: у него можно заменить данные без пересоздания.
extension type MmrGeoJsonSource._(JSObject _) implements JSObject {
  /// Заменяет данные источника.
  external void setData(JSAny data);
}

/// Событие карты, приходящее в обработчик.
extension type MmrMapEvent._(JSObject _) implements JSObject {
  /// Тип события.
  external String get type;

  /// Координата, к которой относится событие.
  external MmrLngLat? get lngLat;

  /// Точка на экране, к которой относится событие.
  external MmrPoint? get point;

  /// Объекты слоя под точкой события.
  external JSArray<MmrFeature>? get features;

  /// Исходное событие браузера: есть только у событий от пользователя.
  external JSAny? get originalEvent;

  /// Идентификатор картинки, если событие — `styleimagemissing`.
  external String? get id;

  /// Ошибка, если событие — `error`.
  external MmrError? get error;

  /// Признак, который плагин передаёт своим перемещениям камеры.
  @JS('vkApiMove')
  external bool? get isApiMove;

  /// Признак перемещения камеры из-за режима следования.
  @JS('vkFollowMove')
  external bool? get isFollowMove;
}

/// Ошибка, о которой сообщила библиотека.
extension type MmrError._(JSObject _) implements JSObject {
  /// Текст ошибки.
  external String? get message;
}

/// Объект слоя, попавший в событие.
extension type MmrFeature._(JSObject _) implements JSObject {
  /// Свойства объекта из источника.
  external JSObject? get properties;
}

/// Кнопки масштабирования и компас.
@JS('mmrgl.NavigationControl')
extension type MmrNavigationControl._(JSObject _) implements JSObject {
  /// Создаёт элемент управления.
  external factory MmrNavigationControl(JSObject options);
}

/// Кнопка определения местоположения браузером.
@JS('mmrgl.GeolocateControl')
extension type MmrGeolocateControl._(JSObject _) implements JSObject {
  /// Создаёт элемент управления.
  external factory MmrGeolocateControl(JSObject options);
}

/// Блок с логотипом VK.
///
/// Карта добавляет его сама при создании (опция `mmrglLogo`), в угол из
/// `logoPosition`. Отдельно он создаётся только затем, чтобы переставить
/// логотип уже после создания карты.
@JS('mmrgl.LogoControl')
extension type MmrLogoControl._(JSObject _) implements JSObject {
  /// Создаёт элемент управления.
  external factory MmrLogoControl([JSObject options]);

  /// Добавляет элемент в документ и возвращает его корень.
  external web.HTMLElement onAdd(MmrMap map);

  /// Убирает элемент из документа.
  external void onRemove(MmrMap map);
}

/// Экспортирует ли загруженная библиотека конструктор блока с логотипом.
///
/// Логотип показывается в любом случае, но переставить его после создания
/// карты можно только через этот конструктор, поэтому наличие проверяется
/// в рантайме.
bool get hasLogoControl =>
    isMmrGlLoaded && (mmrgl as JSObject).has('LogoControl');
