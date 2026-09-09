import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'interop/mmrgl.dart';

/// Загрузка библиотеки `MMR GL JS` на страницу.
///
/// Скрипт и стили подключаются сами при первой инициализации, поэтому
/// править `web/index.html` приложения не нужно. Если библиотека уже есть
/// на странице — подключена вручную или собрана в бандл приложения — она
/// используется как есть и второй раз не загружается.
abstract final class VkMapsSdkLoader {
  /// Адрес, с которого берётся библиотека.
  ///
  /// Меняется до вызова `VkMaps.init`, если SDK раздаётся со своего хоста.
  static String baseUrl = 'https://maps.vk.com/sdk/js';

  /// Версия библиотеки.
  ///
  /// `0` означает последнюю выпущенную версию ветки `0.x.x` — так это
  /// устроено в самом SDK. Для воспроизводимых сборок стоит задать точную
  /// версию.
  static String version = '0';

  static Future<void>? _loading;

  /// Адрес файла скрипта.
  static String get scriptUrl => '$baseUrl/$version/mmr-gl.js';

  /// Адрес файла стилей.
  static String get styleUrl => '$baseUrl/$version/mmr-gl.css';

  /// Загружает библиотеку, если её ещё нет на странице.
  ///
  /// Повторные вызовы во время загрузки ждут ту же загрузку, а не начинают
  /// новую.
  static Future<void> ensureLoaded() {
    if (isMmrGlLoaded) {
      return Future<void>.value();
    }
    return _loading ??= _load();
  }

  /// Забывает результат загрузки. Нужно тестам.
  static void reset() => _loading = null;

  static Future<void> _load() async {
    try {
      _appendStyleSheet();
      await _appendScript();
      if (!isMmrGlLoaded) {
        throw StateError(
          'Скрипт $scriptUrl загрузился, но глобального объекта mmrgl на '
          'странице нет.',
        );
      }
      // Проверка поддержки есть не в каждой сборке SDK: в 0.2.43 метода
      // `supported` нет, и его вызов уронил бы инициализацию на ровном
      // месте. Если метод есть — его ответу верим.
      if (hasSupportedCheck && !mmrgl.supported()) {
        throw StateError(
          'Браузер не поддерживает MMR GL JS: для карты нужен WebGL.',
        );
      }
    } catch (_) {
      // Неудачная попытка не должна закрывать дорогу следующей: адрес или
      // версию можно поправить и вызвать инициализацию снова.
      _loading = null;
      rethrow;
    }
  }

  static void _appendStyleSheet() {
    final String url = styleUrl;
    final web.NodeList existing = web.document.querySelectorAll(
      'link[rel="stylesheet"]',
    );
    for (int i = 0; i < existing.length; i++) {
      final web.Element? node = existing.item(i) as web.Element?;
      if (node.isA<web.HTMLLinkElement>() &&
          (node! as web.HTMLLinkElement).href.contains('mmr-gl')) {
        return;
      }
    }
    final web.HTMLLinkElement link = web.HTMLLinkElement()
      ..rel = 'stylesheet'
      ..href = url;
    web.document.head!.appendChild(link);
  }

  static Future<void> _appendScript() {
    final Completer<void> completer = Completer<void>();
    final web.HTMLScriptElement script = web.HTMLScriptElement()
      ..src = scriptUrl
      ..async = true;

    script.onload = (web.Event _) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }.toJS;
    script.onerror = (JSAny? _) {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError(
            'Не удалось загрузить JavaScript SDK VK Карт с $scriptUrl. '
            'Проверьте доступность адреса и версию '
            '(VkMapsSdkLoader.version).',
          ),
        );
      }
    }.toJS;

    web.document.head!.appendChild(script);
    return completer.future;
  }
}
