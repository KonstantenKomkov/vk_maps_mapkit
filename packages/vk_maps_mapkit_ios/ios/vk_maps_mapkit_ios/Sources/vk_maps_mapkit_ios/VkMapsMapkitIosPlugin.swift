import Flutter
import Foundation
import MapsNativeSDK
import UIKit

/// Точка входа плагина на iOS.
///
/// Регистрирует фабрику нативных представлений и реализации API моста.
public final class VkMapsMapkitIosPlugin: NSObject, FlutterPlugin {
  private static let viewType = "vk_maps_mapkit/map"

  /// Регистрация плагина движком Flutter.
  public static func register(with registrar: FlutterPluginRegistrar) {
    let registry = VkMapViewRegistry()
    let factory = VkMapViewFactory(
      registry: registry,
      binaryMessenger: registrar.messenger()
    )
    registrar.register(factory, withId: viewType)

    VkMapsInitializerApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: VkMapsInitializerApiImpl()
    )
    VkMapsHostApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: VkMapsHostApiImpl(registry: registry)
    )
  }
}

/// Реестр созданных карт: мост обращается к ним по идентификатору.
final class VkMapViewRegistry {
  private var views: [Int64: VkMapPlatformView] = [:]

  func register(_ view: VkMapPlatformView, id: Int64) {
    views[id] = view
  }

  func view(id: Int64) throws -> VkMapPlatformView {
    guard let view = views[id] else {
      throw VkMapsError.unknownView(id)
    }
    return view
  }

  func remove(id: Int64) {
    views.removeValue(forKey: id)?.dispose()
  }
}

/// Фабрика нативных представлений карты.
final class VkMapViewFactory: NSObject, FlutterPlatformViewFactory {
  private let registry: VkMapViewRegistry
  private let binaryMessenger: FlutterBinaryMessenger

  init(registry: VkMapViewRegistry, binaryMessenger: FlutterBinaryMessenger) {
    self.registry = registry
    self.binaryMessenger = binaryMessenger
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    // Параметры карты приходят отдельным вызовом initializeView сразу после
    // создания представления, поэтому аргументы здесь не нужны.
    let view = VkMapPlatformView(
      frame: frame,
      viewId: viewId,
      binaryMessenger: binaryMessenger
    )
    registry.register(view, id: viewId)
    return view
  }
}

/// Разовая настройка SDK.
final class VkMapsInitializerApiImpl: VkMapsInitializerApi {
  private static var isConfigured = false

  func setup(
    apiKey: String,
    baseUrl: String?,
    locale: String?,
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    // Повторный вызов не переинициализирует SDK: так приложение может
    // звать init из нескольких мест, не рискуя уронить карту.
    if Self.isConfigured {
      completion(.success(true))
      return
    }
    let result = MapsSDKConfigurator.setup(
      baseURL: baseUrl ?? "https://maps.vk.com",
      apiKey: apiKey,
      tileCacheOptions: nil,
      modelCacheOptions: nil,
      commonCacheOptions: nil,
      tileReloadIntervals: [],
      styleLoadTimeout: 30,
      tileLoadTimeout: 30,
      sourceLoadTimeout: 30,
      geoJsonLoadTimeout: 30,
      dataLoadTimeout: 30,
      overrideURLSessionConfiguration: nil,
      resourceBundle: nil
    )
    Self.isConfigured = result
    completion(.success(result))
  }

  func isInitialized() throws -> Bool {
    Self.isConfigured
  }
}
