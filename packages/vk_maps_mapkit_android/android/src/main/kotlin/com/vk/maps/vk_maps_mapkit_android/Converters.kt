package com.vk.maps.vk_maps_mapkit_android

import ru.mail.maps.data.LatLon
import ru.mail.maps.data.MapLocation
import ru.mail.maps.data.MapStyle
import ru.mail.maps.data.MarkerEntity
import ru.mail.maps.data.MarkerImage

// Перевод сообщений моста в модели SDK и обратно.

internal fun PlatformLatLon.toMapLocation(): MapLocation =
  MapLocation(latitude = latitude, longitude = longitude)

internal fun PlatformLatLon.toLatLon(): LatLon = LatLon(latitude, longitude)

internal fun MapLocation.toPlatformLatLon(): PlatformLatLon =
  PlatformLatLon(latitude ?: 0.0, longitude ?: 0.0)

internal fun PlatformMarker.toMarkerEntity(): MarkerEntity =
  MarkerEntity(
    id = markerId,
    coordinates = position.toMapLocation(),
    image = imageId.toMarkerImage(),
  )

/**
 * Картинка маркера по идентификатору из Dart-API.
 *
 * На iOS изображение добавляется в стиль и адресуется своим идентификатором,
 * а документированный Android SDK принимает только значения из встроенного
 * перечисления. Поэтому идентификатор сопоставляется с именем значения;
 * если совпадения нет, берётся первое значение перечисления, чтобы маркер
 * всё-таки появился на карте.
 */
internal fun String.toMarkerImage(): MarkerImage =
  MarkerImage.values().firstOrNull { it.name.equals(this, ignoreCase = true) }
    ?: MarkerImage.values().first()

/**
 * Стиль карты для SDK.
 *
 * Возвращает `null`, если способ задания стиля на Android недоступен:
 * документированный SDK принимает только предопределённые стили и ссылку.
 */
internal fun PlatformStyle.toMapStyle(): MapStyle? = when (kind) {
  PlatformStyleKind.PREDEFINED -> when (predefined) {
    PlatformPredefinedStyle.DARK -> MapStyle.Dark
    PlatformPredefinedStyle.SIMPLE, PlatformPredefinedStyle.SIMPLE_DARK -> MapStyle.Simple
    else -> MapStyle.Main
  }
  PlatformStyleKind.URL -> url?.let { MapStyle.Custom(it) }
  PlatformStyleKind.JSON -> null
}
