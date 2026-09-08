package com.vk.maps.vk_maps_mapkit_android

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import ru.mail.maps.data.LatLon
import ru.mail.maps.data.MapLocation
import ru.mail.maps.data.MapStyle
import ru.mail.maps.data.MarkerEntity
import ru.mail.maps.sdk.Map
import ru.mail.maps.sdk.views.MapView

/**
 * Нативное представление карты внутри дерева Flutter.
 *
 * Объект [Map] приходит асинхронно через `getMapAsync`, поэтому вызовы до
 * его появления складываются в очередь: иначе первые же команды из Dart
 * пропали бы молча.
 */
internal class VkMapPlatformView(
  context: Context,
  private val viewId: Long,
  binaryMessenger: BinaryMessenger,
) : PlatformView {

  private val container = FrameLayout(context)
  private val mapView = MapView(context)
  private val flutterApi = VkMapsFlutterApi(binaryMessenger)
  private val pending = mutableListOf<(Map) -> Unit>()
  private var map: Map? = null

  /** Соответствие «идентификатор маркера в Dart → маркер SDK». */
  private val markers = mutableMapOf<String, MarkerEntity>()

  private var lastZoom: Double = 0.0
  private var lastCenter: LatLon? = null

  init {
    container.addView(
      mapView,
      FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT,
      ),
    )
  }

  override fun getView(): View = container

  override fun dispose() {
    map?.removeMarkerClickListener()
    map?.removeZoomChangedListener()
    markers.clear()
    pending.clear()
    map = null
  }

  /** Создаёт карту по параметрам, пришедшим из Dart. */
  fun initialize(params: PlatformMapCreationParams) {
    if (map != null) return

    val camera = params.initialCameraPosition
    lastCenter = LatLon(camera.target.latitude, camera.target.longitude)
    lastZoom = camera.zoom

    mapView.getMapAsync { created ->
      map = created
      created.setCenter(camera.target.toMapLocation(), animated = false)
      created.setZoom(camera.zoom.toFloat(), animated = false)
      created.setBearing(camera.bearing.toFloat(), animated = false)
      attachListeners(created)
      apply(params.configuration)
      pending.forEach { action -> action(created) }
      pending.clear()
      send(PlatformMapEvent(type = PlatformMapEventType.MAP_SHOWN))
    }
  }

  private fun attachListeners(map: Map) {
    map.setOnMapClickListener { location, screen ->
      send(tapEvent(PlatformMapEventType.TAP, location, screen))
    }
    map.setOnMapLongClickListener { location, screen ->
      send(tapEvent(PlatformMapEventType.LONG_TAP, location, screen))
    }
    map.setOnMarkerClickListener { id, location ->
      send(
        PlatformMapEvent(
          type = PlatformMapEventType.MARKER_TAP,
          markerId = id,
          position = location.toPlatformLatLon(),
        )
      )
    }
    map.setOnZoomChangedListener { zoom ->
      lastZoom = zoom
      send(
        PlatformMapEvent(
          type = PlatformMapEventType.CAMERA_MOVE,
          cameraPosition = cameraPosition(),
          cameraMovingReason = PlatformCameraMovingReason.UNKNOWN,
          cameraMovingPhase = PlatformCameraMovingPhase.MOVING,
        )
      )
    }
    map.addOnErrorListener { error ->
      send(
        PlatformMapEvent(
          type = PlatformMapEventType.ERROR,
          errorCode = error.javaClass.simpleName,
          errorMessage = error.message ?: "",
        )
      )
    }
  }

  /** Выполняет действие с картой сразу или после её появления. */
  private fun withMap(action: (Map) -> Unit) {
    val ready = map
    if (ready != null) action(ready) else pending.add(action)
  }

  fun apply(configuration: PlatformMapConfiguration) = withMap { map ->
    configuration.scrollGesturesEnabled?.let { map.enableDragPan(it) }
    val gestures = configuration.zoomGesturesEnabled ?: configuration.rotateGesturesEnabled
    if (gestures != null) map.enableZoomRotate(gestures)
    configuration.style?.let { style ->
      style.toMapStyle()?.let { map.changeStyle(it) }
        ?: send(
          PlatformMapEvent(
            type = PlatformMapEventType.ERROR,
            errorCode = "style_unsupported",
            errorMessage = "Такой способ задания стиля SDK на Android не поддерживает",
          )
        )
    }
  }

  fun apply(updates: PlatformMarkerUpdates) = withMap { map ->
    updates.idsToRemove.forEach { id ->
      markers.remove(id)
      map.removeMarker(id)
    }
    updates.toChange.forEach { marker ->
      // Отдельного метода обновления у SDK нет: маркер пересоздаётся.
      map.removeMarker(marker.markerId)
      addMarker(map, marker)
    }
    updates.toAdd.forEach { marker -> addMarker(map, marker) }
  }

  private fun addMarker(map: Map, marker: PlatformMarker) {
    if (!marker.visible) return
    val entity = marker.toMarkerEntity()
    markers[marker.markerId] = entity
    map.addMarker(entity)
  }

  fun moveCamera(
    target: PlatformLatLon?,
    options: PlatformCameraOptions?,
    animation: PlatformAnimationOptions?,
    callback: (PlatformCameraAnimationResult) -> Unit,
  ) = withMap { map ->
    val animated = (animation?.durationMillis ?: 0L) > 0L
    target?.let { point ->
      lastCenter = LatLon(point.latitude, point.longitude)
      map.flyTo(
        point.toMapLocation(),
        animated,
        animation?.durationMillis?.toInt(),
      )
    }
    options?.zoom?.let { zoom ->
      lastZoom = zoom
      map.setZoom(zoom.toFloat(), animated)
    }
    options?.bearing?.let { bearing -> map.setBearing(bearing.toFloat(), animated) }
    // SDK не сообщает о завершении анимации, поэтому результат — «дошли».
    callback(PlatformCameraAnimationResult.FINISHED)
  }

  fun cameraPosition(): PlatformCameraPosition {
    val center = lastCenter ?: LatLon(0.0, 0.0)
    return PlatformCameraPosition(
      target = PlatformLatLon(center.lat, center.lon),
      zoom = lastZoom,
      bearing = 0.0,
      pitch = 0.0,
    )
  }

  fun setUserLocation(coordinates: PlatformLatLon?, bearing: Double?, accuracy: Double?) =
    withMap { map ->
      // Позиция пользователя на Android задаётся источником: SDK сам просит
      // данные, когда они ему нужны.
      map.setLocationSource(
        FlutterLocationSource(
          coordinates?.let {
            MapLocation(
              latitude = it.latitude,
              longitude = it.longitude,
              bearing = bearing?.toFloat(),
              accuracy = accuracy?.toFloat(),
            )
          }
        )
      )
    }

  private fun tapEvent(
    type: PlatformMapEventType,
    location: MapLocation,
    screen: ru.mail.maps.data.ScreenLocation,
  ) = PlatformMapEvent(
    type = type,
    position = location.toPlatformLatLon(),
    screenPoint = PlatformScreenPoint(screen.x.toDouble(), screen.y.toDouble()),
  )

  private fun send(event: PlatformMapEvent) {
    flutterApi.onEvent(viewId, event) { }
  }
}

/**
 * Источник позиции, отдающий SDK последнюю точку, присланную из Flutter.
 *
 * Плагин не работает с геолокацией сам: разрешения и подписку на систему
 * держит приложение.
 */
internal class FlutterLocationSource(private val location: MapLocation?) :
  ru.mail.maps.sdk.LocationSource {

  private var listener: ((MapLocation) -> Unit)? = null

  override fun activate(listener: (mapLocation: MapLocation) -> Unit) {
    this.listener = listener
    location?.let(listener)
  }

  override fun deactivate() {
    listener = null
  }
}
