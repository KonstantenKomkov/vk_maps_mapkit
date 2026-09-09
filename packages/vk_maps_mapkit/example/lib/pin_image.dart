import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vk_maps_mapkit/vk_maps_mapkit.dart';

/// Идентификатор картинки маркера в стиле карты.
///
/// Маркер не носит картинку в себе: он ссылается на изображение стиля,
/// поэтому картинку нужно положить туда до показа маркеров.
const String pinImageId = 'pin';

/// Кладёт картинку маркера в стиль карты.
///
/// Вызывается после создания карты и повторно после смены стиля: смена
/// пересобирает стиль целиком, и картинки в нём нужно восстановить.
Future<void> addPinImage(VkMapController controller) async =>
    controller.addStyleImage(
      pinImageId,
      await drawPin(),
      // Картинка нарисована в двойном разрешении: на карте она займёт
      // 24 × 32 логических пикселя.
      scale: 2,
    );

/// Рисует каплю маркера и кодирует её в PNG.
///
/// Картинка собирается кодом, а не лежит ассетом: так пример остаётся
/// самодостаточным и одинаково работает на всех платформах.
Future<Uint8List> drawPin({Color color = const Color(0xFF0077FF)}) async {
  const double width = 48;
  const double height = 64;
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  final Path body = Path()
    ..moveTo(width / 2, height)
    ..cubicTo(width / 2 - 22, height - 26, 2, height - 34, 2, 22)
    ..arcToPoint(
      const Offset(width - 2, 22),
      radius: const Radius.circular(22),
      clockwise: true,
    )
    ..cubicTo(
      width - 2,
      height - 34,
      width / 2 + 22,
      height - 26,
      width / 2,
      height,
    )
    ..close();

  canvas
    ..drawPath(body, Paint()..color = color)
    ..drawPath(
      body,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    )
    ..drawCircle(
      const Offset(width / 2, 22),
      8,
      Paint()..color = const Color(0xFFFFFFFF),
    );

  final ui.Image image = await recorder.endRecording().toImage(
    width.toInt(),
    height.toInt(),
  );
  final ByteData? png = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return png!.buffer.asUint8List();
}
