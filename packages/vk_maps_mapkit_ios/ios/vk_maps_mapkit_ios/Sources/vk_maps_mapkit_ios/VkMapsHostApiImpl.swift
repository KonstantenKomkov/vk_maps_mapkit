import Flutter
import Foundation
import MapsNativeSDK

/// Реализация методов моста поверх реестра карт.
final class VkMapsHostApiImpl: VkMapsHostApi {
  private let registry: VkMapViewRegistry

  init(registry: VkMapViewRegistry) {
    self.registry = registry
  }

  func initializeView(
    viewId: Int64,
    params: PlatformMapCreationParams,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    do {
      try registry.view(id: viewId).initialize(params: params)
      completion(.success(()))
    } catch {
      completion(.failure(error))
    }
  }

  func updateConfiguration(
    viewId: Int64,
    configuration: PlatformMapConfiguration
  ) throws {
    try registry.view(id: viewId).apply(configuration: configuration)
  }

  func updateMarkers(viewId: Int64, updates: PlatformMarkerUpdates) throws {
    try registry.view(id: viewId).apply(markerUpdates: updates)
  }

  func moveCamera(
    viewId: Int64,
    target: PlatformLatLon?,
    options: PlatformCameraOptions?,
    animation: PlatformAnimationOptions?,
    completion: @escaping (Result<PlatformCameraAnimationResult, Error>) -> Void
  ) {
    do {
      let camera = try registry.view(id: viewId).camera()
      let coordinates: MapCameraCoordinates? = target.map { .center($0.coordinates) }
      camera.flyTo(
        coordinates: coordinates,
        cameraOptions: options?.native,
        animationOptions: animation?.native,
        reason: nil,
        resetFollowingMode: false
      ) { result in
        completion(.success(result.message))
      }
    } catch {
      completion(.failure(error))
    }
  }

  func fitBounds(
    viewId: Int64,
    bounds: PlatformLatLonBounds,
    padding: PlatformEdgeInsets,
    animation: PlatformAnimationOptions?,
    completion: @escaping (Result<PlatformCameraAnimationResult, Error>) -> Void
  ) {
    do {
      let camera = try registry.view(id: viewId).camera()
      let duration = Double(animation?.durationMillis ?? 0) / 1000.0
      camera.fitBounds(
        MapBounds(
          southwest: bounds.southwest.coordinates,
          northeast: bounds.northeast.coordinates
        ),
        padding: padding.mapEdgeInsets,
        animationDuration: duration,
        reason: nil
      ) { result in
        completion(.success(result.message))
      }
    } catch {
      completion(.failure(error))
    }
  }

  func getCameraPosition(viewId: Int64) throws -> PlatformCameraPosition {
    try registry.view(id: viewId).cameraPositionMessage()
  }

  func getVisibleBounds(viewId: Int64) throws -> PlatformLatLonBounds {
    try registry.view(id: viewId).visibleBoundsMessage()
  }

  func coordinateForScreenPoint(
    viewId: Int64,
    point: PlatformScreenPoint
  ) throws -> PlatformLatLon? {
    try registry.view(id: viewId).coordinate(for: point)
  }

  func screenPointForCoordinate(
    viewId: Int64,
    coordinate: PlatformLatLon
  ) throws -> PlatformScreenPoint? {
    // Обратной проекции в нативном SDK нет: в CameraController есть только
    // coordinatesByViewPoint. Метод помечен как неподдержанный, чтобы
    // приложение получило внятный отказ, а не молчаливый null.
    throw PigeonError(
      code: "unsupported",
      message: "Проекция координаты в точку экрана не поддерживается на iOS",
      details: nil
    )
  }

  func getMode(viewId: Int64) throws -> PlatformMapMode {
    try registry.view(id: viewId).mode().message
  }

  func setMode(viewId: Int64, mode: PlatformMapMode) throws {
    try registry.view(id: viewId).setMode(mode.native)
  }

  func setUserLocation(
    viewId: Int64,
    coordinates: PlatformLatLon?,
    bearing: Double?,
    accuracy: Double?,
    visible: Bool
  ) throws {
    try registry.view(id: viewId).setUserLocation(
      coordinates: coordinates,
      bearing: bearing,
      accuracy: accuracy,
      visible: visible
    )
  }

  func addStyleImage(
    viewId: Int64,
    imageId: String,
    pngBytes: FlutterStandardTypedData,
    scale: Double,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    do {
      try registry.view(id: viewId).addStyleImage(
        imageId: imageId,
        pngData: pngBytes.data,
        scale: scale
      )
      completion(.success(()))
    } catch {
      completion(.failure(error))
    }
  }

  func removeStyleImage(viewId: Int64, imageId: String) throws {
    try registry.view(id: viewId).removeStyleImage(imageId: imageId)
  }

  func dispose(viewId: Int64) throws {
    registry.remove(id: viewId)
  }
}
