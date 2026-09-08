import Flutter
import Foundation
import MapsNativeSDK
import UIKit

/// Нативное представление карты, живущее в дереве Flutter.
///
/// Держит `MapView`, соответствие «строковый идентификатор маркера →
/// числовой идентификатор SDK» и отправляет события во Flutter.
final class VkMapPlatformView: NSObject, FlutterPlatformView, MapViewDelegate {
  private let viewId: Int64
  private let container: UIView
  private let flutterApi: VkMapsFlutterApi
  private var mapView: MapView?

  /// Маркеры SDK нумеруются `UInt32`, а в Dart-API идентификатор строковый:
  /// соответствие хранится здесь.
  private var markerIds: [String: UInt32] = [:]
  private var nextMarkerId: UInt32 = 1

  init(frame: CGRect, viewId: Int64, binaryMessenger: FlutterBinaryMessenger) {
    self.viewId = viewId
    self.container = UIView(frame: frame)
    self.flutterApi = VkMapsFlutterApi(binaryMessenger: binaryMessenger)
    super.init()
    container.backgroundColor = .clear
  }

  /// Создаёт карту по параметрам, пришедшим из Dart сразу после появления
  /// представления. Повторный вызов игнорируется.
  func initialize(params: PlatformMapCreationParams) {
    guard mapView == nil else { return }

    let camera = params.initialCameraPosition
    let selectFeatures: FeaturesSelectionMode
    switch params.configuration.featuresSelectionMode {
    case .some(.handleEvents): selectFeatures = .handleEvents
    case .some(.drawSelection): selectFeatures = .drawSelection
    case .some(.all): selectFeatures = .all
    default: selectFeatures = .none
    }

    let configuration = MapConfiguration(
      center: camera.target.coordinates,
      zoom: camera.zoom,
      pitch: Angle(degrees: camera.pitch),
      maxPitch: Angle(degrees: 60),
      bearing: Angle(degrees: camera.bearing),
      predefinedStyle: params.configuration.style?.predefined?.native ?? .main,
      fonts: [],
      selectFeatures: selectFeatures,
      cameraMode: .perspective
    )

    let map = MapView(
      frame: container.bounds,
      configuration: configuration,
      delegate: self
    )
    map.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(map)
    NSLayoutConstraint.activate([
      map.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      map.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      map.topAnchor.constraint(equalTo: container.topAnchor),
      map.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])
    mapView = map
    apply(configuration: params.configuration)
  }

  private func requireMap() throws -> MapView {
    guard let mapView else {
      throw VkMapsError.notInitialized(viewId)
    }
    return mapView
  }

  func view() -> UIView {
    container
  }

  // MARK: - Настройки

  /// Применяет дельту настроек: пустые поля означают «не менять».
  func apply(configuration: PlatformMapConfiguration) {
    guard let mapView else { return }
    if let value = configuration.compassEnabled { mapView.showsCompass = value }
    if let value = configuration.zoomButtonsEnabled { mapView.showsZoomButtons = value }
    if let value = configuration.currentLocationButtonEnabled {
      mapView.isCurrentLocationButtonVisible = value
    }
    if let value = configuration.scrollGesturesEnabled {
      mapView.isScrollGesturesEnabled = value
    }
    if let value = configuration.zoomGesturesEnabled {
      mapView.isZoomGesturesEnabled = value
    }
    if let value = configuration.rotateGesturesEnabled {
      mapView.isRotateGesturesEnabled = value
    }
    if let value = configuration.logoAlignment { mapView.logoAlignment = value.native }
    if let value = configuration.logoInsets { mapView.logoInsets = value.mapEdgeInsets }
    if let value = configuration.logoIgnoresSafeArea { mapView.logoIgnoresSafeArea = value }
    if let value = configuration.padding {
      mapView.camera.setPadding(value.mapEdgeInsets, animationDuration: 0, reason: nil)
    }
    if configuration.minZoom != nil || configuration.maxZoom != nil {
      // Границы зума задаются одним вызовом; незаданная сторона остаётся
      // прежней.
      mapView.camera.setZoomRange(
        minZoom: configuration.minZoom ?? mapView.camera.minZoom,
        maxZoom: configuration.maxZoom ?? mapView.camera.maxZoom
      )
    }
    if let style = configuration.style { apply(style: style) }
  }

  private func apply(style: PlatformStyle) {
    Task { [weak self] in
      guard let self else { return }
      do {
        let mapStyle: MapStyle
        switch style.kind {
        case .predefined:
          mapStyle = try await MapStyle(predefinedStyle: style.predefined?.native ?? .main)
        case .json:
          mapStyle = try await MapStyle(json: style.json ?? "")
        case .url:
          guard let raw = style.url, let url = URL(string: raw) else {
            self.send(error: "style_url", message: "Некорректная ссылка на стиль")
            return
          }
          mapStyle = try await MapStyle(url: url)
        }
        await MainActor.run { self.mapView?.setStyle(mapStyle, force: false) }
      } catch {
        self.send(error: "style_load", message: error.localizedDescription)
      }
    }
  }

  // MARK: - Маркеры

  func apply(markerUpdates updates: PlatformMarkerUpdates) {
    guard let mapView else { return }
    for id in updates.idsToRemove {
      if let nativeId = markerIds.removeValue(forKey: id) {
        mapView.overlay.removeMarker(id: nativeId)
      }
    }
    for marker in updates.toChange {
      if let nativeId = markerIds[marker.markerId] {
        mapView.overlay.removeMarker(id: nativeId)
        markerIds.removeValue(forKey: marker.markerId)
      }
      add(marker: marker)
    }
    for marker in updates.toAdd {
      add(marker: marker)
    }
  }

  private func add(marker: PlatformMarker) {
    guard marker.visible, let mapView else { return }
    let nativeId = nextMarkerId
    nextMarkerId &+= 1
    markerIds[marker.markerId] = nativeId
    mapView.overlay.addMarker(
      Marker(
        id: nativeId,
        coordinates: marker.position.coordinates,
        imageID: marker.imageId,
        alignment: marker.alignment.native,
        zIndex: Int32(marker.zIndex)
      )
    )
  }

  private func markerKey(for nativeId: UInt32) -> String? {
    markerIds.first { $0.value == nativeId }?.key
  }

  // MARK: - Камера и проекции

  func camera() throws -> CameraController { try requireMap().camera }

  func cameraPositionMessage() throws -> PlatformCameraPosition {
    let camera = try requireMap().camera
    return PlatformCameraPosition(
      target: camera.centerCoordinates.message,
      zoom: camera.zoom,
      bearing: camera.bearing,
      pitch: camera.pitch
    )
  }

  func visibleBoundsMessage() throws -> PlatformLatLonBounds {
    let bounds = try requireMap().camera.mapBounds
    return PlatformLatLonBounds(
      southwest: bounds.southwest.message,
      northeast: bounds.northeast.message
    )
  }

  func coordinate(for point: PlatformScreenPoint) throws -> PlatformLatLon? {
    try requireMap().camera.coordinatesByViewPoint(point.cgPoint)?.message
  }

  func mode() throws -> MapMode { try requireMap().mode }

  func setMode(_ mode: MapMode) throws { try requireMap().setMode(mode) }

  func setUserLocation(
    coordinates: PlatformLatLon?,
    bearing: Double?,
    accuracy: Double?,
    visible: Bool
  ) throws {
    let mapView = try requireMap()
    mapView.userPointer.isVisible = visible
    mapView.userPointer.setCurrentLocation(
      coordinates: coordinates?.coordinates,
      bearing: bearing,
      accuracy: accuracy,
      animationDuration: nil
    )
  }

  func addStyleImage(imageId: String, pngData: Data, scale: Double) throws {
    guard let style = try requireMap().style else {
      throw VkMapsError.styleNotReady
    }
    try style.addImage(
      imageID: imageId,
      pngImageData: pngData,
      scale: CGFloat(scale)
    )
  }

  func removeStyleImage(imageId: String) {
    mapView?.style?.removeImage(imageID: imageId)
  }

  // MARK: - Источники и слои

  private func requireStyle() throws -> MapStyle {
    guard let style = try requireMap().style else {
      throw VkMapsError.styleNotReady
    }
    return style
  }

  func addGeoJsonSource(sourceId: String, geoJson: String) throws {
    let source = try MapDataSource(
      id: sourceId,
      json: geoJson,
      type: .geoJSON,
      receiveTapEvents: true
    )
    try requireStyle().addSource(source)
  }

  func setGeoJsonSourceData(sourceId: String, geoJson: String) throws {
    guard let source = try requireStyle().source(by: sourceId) else {
      throw VkMapsError.unknownSource(sourceId)
    }
    source.setGeoJSON(geoJson)
  }

  func addEncodedPolylineSource(sourceId: String, polyline: String) throws {
    let source = try MapDataSource(
      id: sourceId,
      encodedString: polyline,
      type: .geoJSON,
      receiveTapEvents: true
    )
    try requireStyle().addSource(source)
  }

  func removeSource(sourceId: String) throws {
    try requireStyle().removeSource(by: sourceId)
  }

  func addLayer(layerJson: String, beforeLayerId: String?) throws {
    let layer = try MapLayer(json: layerJson)
    let style = try requireStyle()
    if let beforeLayerId {
      try style.insertLayer(layer, before: beforeLayerId)
    } else {
      try style.addLayer(layer)
    }
  }

  func removeLayer(layerId: String) throws {
    try requireStyle().removeLayer(by: layerId)
  }

  func setLayerVisibility(layerId: String, visible: Bool) throws {
    guard let layer = try requireStyle().layer(by: layerId) else {
      throw VkMapsError.unknownLayer(layerId)
    }
    layer.isVisible = visible
  }

  func dispose() {
    // Отдельного метода освобождения у MapView нет: карта убирается из
    // иерархии и отпускается, дальше её освобождает deinit SDK.
    mapView?.delegate = nil
    markerIds.removeAll()
    mapView?.overlay.removeAllMarkers()
    mapView?.reduceMemoryUse()
    mapView?.removeFromSuperview()
    mapView = nil
  }

  // MARK: - MapViewDelegate

  func mapView(_ mapView: MapView, didReceiveEvent event: MapEvent) {
    switch event {
    case .mapDidShow:
      send(PlatformMapEvent(type: .mapShown))
    case let .tap(coordinates):
      send(tapEvent(type: .tap, coordinates: coordinates))
    case let .longTap(coordinates):
      send(tapEvent(type: .longTap, coordinates: coordinates))
    case let .markerDidSelect(id, coordinates):
      send(
        PlatformMapEvent(
          type: .markerTap,
          position: coordinates.geoCoordinates.message,
          markerId: markerKey(for: id)
        )
      )
    case let .cameraDidMove(state, reason, phase):
      send(
        PlatformMapEvent(
          type: .cameraMove,
          cameraPosition: PlatformCameraPosition(
            target: state.center.message,
            zoom: state.zoom,
            bearing: state.bearing,
            pitch: state.pitch
          ),
          cameraMovingReason: reason.message,
          cameraMovingPhase: phase.message
        )
      )
    case .styleDidApply:
      send(PlatformMapEvent(type: .styleApplied))
    case .lowMemoryWarning:
      send(PlatformMapEvent(type: .lowMemory))
    case let .tileDidFail(_, message), let .tileDidFailLoad(_, message):
      send(error: "tile_load", message: message)
    case .gpuError:
      send(error: "gpu", message: "Ошибка графической подсистемы")
    default:
      // Остальные события SDK в контракт плагина не входят: их появление
      // не должно ломать поток.
      break
    }
  }

  func mapView(_ mapView: MapView, didChangeModeTo mode: MapMode) {
    send(PlatformMapEvent(type: .modeChanged, mode: mode.message))
  }

  func mapView(_ mapView: MapView, willChangeModeTo mode: MapMode) -> MapMode {
    mode
  }

  func mapView(_ mapView: MapView, didFailWithError error: Error) {
    send(error: "sdk", message: error.localizedDescription)
  }

  // MARK: - Отправка событий

  private func tapEvent(
    type: PlatformMapEventType,
    coordinates: MapEvent.EventCoordinates
  ) -> PlatformMapEvent {
    PlatformMapEvent(
      type: type,
      position: coordinates.geoCoordinates.message,
      screenPoint: PlatformScreenPoint(
        x: Double(coordinates.uiCoordinates.x),
        y: Double(coordinates.uiCoordinates.y)
      )
    )
  }

  private func send(error code: String, message: String) {
    send(PlatformMapEvent(type: .error, errorCode: code, errorMessage: message))
  }

  private func send(_ event: PlatformMapEvent) {
    flutterApi.onEvent(viewId: viewId, event: event) { _ in }
  }
}

/// Ошибки нативной части плагина.
enum VkMapsError: Error {
  /// Карты с таким идентификатором нет в реестре.
  case unknownView(Int64)
  /// Карта ещё не создана: не пришли параметры создания.
  case notInitialized(Int64)
  /// Стиль ещё не загружен, работать с его содержимым рано.
  case styleNotReady
  /// В стиле нет источника с таким идентификатором.
  case unknownSource(String)
  /// В стиле нет слоя с таким идентификатором.
  case unknownLayer(String)
}
