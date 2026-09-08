package com.vk.maps.vk_maps_mapkit_android

/**
 * Реализация методов моста поверх реестра карт.
 *
 * Методы, которых нет в документированном Android SDK, отвечают явной
 * ошибкой: приложение должно узнавать о разнице платформ, а не получать
 * молчаливый `null`.
 */
internal class VkMapsHostApiImpl(private val registry: VkMapViewRegistry) : VkMapsHostApi {

  override fun initializeView(
    viewId: Long,
    params: PlatformMapCreationParams,
    callback: (Result<Unit>) -> Unit,
  ) {
    callback(runCatching { registry.require(viewId).initialize(params) })
  }

  override fun updateConfiguration(viewId: Long, configuration: PlatformMapConfiguration) {
    registry.require(viewId).apply(configuration)
  }

  override fun updateMarkers(viewId: Long, updates: PlatformMarkerUpdates) {
    registry.require(viewId).apply(updates)
  }

  override fun moveCamera(
    viewId: Long,
    target: PlatformLatLon?,
    options: PlatformCameraOptions?,
    animation: PlatformAnimationOptions?,
    callback: (Result<PlatformCameraAnimationResult>) -> Unit,
  ) {
    runCatching {
      registry.require(viewId).moveCamera(target, options, animation) { result ->
        callback(Result.success(result))
      }
    }.onFailure { error -> callback(Result.failure(error)) }
  }

  override fun fitBounds(
    viewId: Long,
    bounds: PlatformLatLonBounds,
    padding: PlatformEdgeInsets,
    animation: PlatformAnimationOptions?,
    callback: (Result<PlatformCameraAnimationResult>) -> Unit,
  ) {
    // Вписывания области в документированном SDK нет: центрируемся на
    // середине области, зум оставляем прежним.
    val center = PlatformLatLon(
      (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
      (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
    )
    runCatching {
      registry.require(viewId).moveCamera(center, null, animation) { result ->
        callback(Result.success(result))
      }
    }.onFailure { error -> callback(Result.failure(error)) }
  }

  override fun getCameraPosition(viewId: Long): PlatformCameraPosition =
    registry.require(viewId).cameraPosition()

  override fun getVisibleBounds(viewId: Long): PlatformLatLonBounds =
    throw FlutterError(
      "unsupported",
      "Границы видимой области на Android недоступны в документированном SDK",
      null,
    )

  override fun coordinateForScreenPoint(
    viewId: Long,
    point: PlatformScreenPoint,
  ): PlatformLatLon? = throw FlutterError(
    "unsupported",
    "Проекция точки экрана в координату на Android недоступна",
    null,
  )

  override fun screenPointForCoordinate(
    viewId: Long,
    coordinate: PlatformLatLon,
  ): PlatformScreenPoint? = throw FlutterError(
    "unsupported",
    "Проекция координаты в точку экрана на Android недоступна",
    null,
  )

  override fun getMode(viewId: Long): PlatformMapMode = PlatformMapMode.FREE

  override fun setMode(viewId: Long, mode: PlatformMapMode) {
    if (mode != PlatformMapMode.FREE) {
      throw FlutterError(
        "unsupported",
        "Режимы следования на Android задаются кнопкой CurrentLocationView",
        null,
      )
    }
  }

  override fun setUserLocation(
    viewId: Long,
    coordinates: PlatformLatLon?,
    bearing: Double?,
    accuracy: Double?,
    visible: Boolean,
  ) {
    registry.require(viewId).setUserLocation(coordinates, bearing, accuracy)
  }

  override fun addStyleImage(
    viewId: Long,
    imageId: String,
    pngBytes: ByteArray,
    scale: Double,
    callback: (Result<Unit>) -> Unit,
  ) {
    callback(
      Result.failure(
        FlutterError(
          "unsupported",
          "Добавление изображений в стиль на Android недоступно: маркеры " +
            "используют встроенный набор картинок",
          null,
        )
      )
    )
  }

  override fun removeStyleImage(viewId: Long, imageId: String) {
    throw FlutterError(
      "unsupported",
      "Изображения стиля на Android недоступны",
      null,
    )
  }

  override fun dispose(viewId: Long) {
    registry.remove(viewId)
  }
}
