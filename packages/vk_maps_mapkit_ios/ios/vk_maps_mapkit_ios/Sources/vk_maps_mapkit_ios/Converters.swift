import Foundation
import MapsNativeSDK
import UIKit

// Перевод сообщений моста в типы нативного SDK и обратно.
// Держится отдельным файлом, чтобы реализация API оставалась читаемой.

extension PlatformLatLon {
  var coordinates: Coordinates {
    Coordinates(lng: longitude, lat: latitude)
  }
}

extension Coordinates {
  var message: PlatformLatLon {
    PlatformLatLon(latitude: lat, longitude: lng)
  }
}

extension PlatformEdgeInsets {
  var mapEdgeInsets: MapEdgeInsets {
    MapEdgeInsets(top: top, left: left, bottom: bottom, right: right)
  }
}

extension PlatformScreenPoint {
  var cgPoint: CGPoint {
    CGPoint(x: x, y: y)
  }
}

extension PlatformPredefinedStyle {
  var native: MapPredefinedStyle {
    switch self {
    case .main: return .main
    case .dark: return .dark
    case .grayLight: return .grayLight
    case .simple: return .simple
    case .simpleDark: return .simpleDark
    case .navigationMain: return .navigationMain
    case .navigationDark: return .navigationDark
    }
  }
}

extension PlatformMapMode {
  var native: MapMode {
    switch self {
    case .free: return .free
    case .followLocation: return .followLocation
    case .followBearingAndLocation: return .followBearingAndLocation
    }
  }
}

extension MapMode {
  var message: PlatformMapMode {
    switch self {
    case .free: return .free
    case .followLocation: return .followLocation
    case .followBearingAndLocation: return .followBearingAndLocation
    @unknown default: return .free
    }
  }
}

extension PlatformLogoAlignment {
  var native: MapLogoAlignment {
    switch self {
    case .topLeft: return .topLeft
    case .topRight: return .topRight
    case .bottomLeft: return .bottomLeft
    case .bottomRight: return .bottomRight
    }
  }
}

extension PlatformMarkerAlignment {
  var native: MarkerImageAlignment {
    switch self {
    case .center: return .center
    case .top: return .top
    case .bottom: return .bottom
    case .left: return .left
    case .right: return .right
    case .topLeft: return .topLeft
    case .topRight: return .topRight
    case .bottomLeft: return .bottomLeft
    case .bottomRight: return .bottomRight
    }
  }
}

extension PlatformAnimationOptions {
  var native: MapAnimationOptions {
    let seconds = Double(durationMillis) / 1000.0
    let easing: MapAnimationEasing
    switch self.easing {
    case .linear: easing = .linear
    case .easeIn: easing = .easeIn
    case .easeOut: easing = .easeOut
    case .easeInOut: easing = .easeInOut
    }
    switch durationMode {
    case .exact:
      return MapAnimationOptions(easing: easing, duration: .linear(value: seconds))
    case .atMost:
      return MapAnimationOptions(easing: easing, duration: .max(value: seconds))
    }
  }
}

extension PlatformCameraOptions {
  var native: MapCameraOptions {
    MapCameraOptions(
      bearing: bearing,
      zoom: zoom,
      pitch: pitch,
      padding: padding?.mapEdgeInsets
    )
  }
}

extension MapCameraAnimationResult {
  var message: PlatformCameraAnimationResult {
    switch self {
    case .finished: return .finished
    default: return .cancelled
    }
  }
}

extension MapEvent.CameraMovingReason {
  var message: PlatformCameraMovingReason {
    switch self {
    case .gesture, .inertia:
      return .gesture
    case .gesture(type: _):
      return .gesture
    case .followMode:
      return .followMode
    default:
      // control, custom, code — всё это программные изменения камеры.
      return .api
    }
  }
}

extension MapEvent.CameraMovingPhase {
  var message: PlatformCameraMovingPhase {
    switch self {
    case .began:
      return .started
    case .changed:
      return .moving
    case .cancelled:
      return .cancelled
    case .singleCompleted, .singeCompleted:
      return .singleCompleted
    default:
      // ended, finished и всё, что появится позже, — завершение движения.
      return .allCompleted
    }
  }
}
