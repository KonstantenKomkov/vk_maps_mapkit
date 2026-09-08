# Поверхность нативного API и её отражение в контракте

Что из нативных SDK используется плагином и под каким именем это видно из
Dart. Таблица нужна, чтобы при обновлении SDK было видно, какие вызовы
затронуты, и чтобы новый метод контракта не появлялся без опоры на SDK.

Источники: DocC-архив `MapsNativeSDK` из релиза 1.4.4.14633 (iOS) и страница
`dev.vk.ru/ru/vkmaps/maps-mobile-sdk/android` (Android). Сверено 8 сентября
2026.

## Настройка SDK

| Контракт | iOS | Android |
| --- | --- | --- |
| `VkMapsInitializerApi.setup` | `MapsSDKConfigurator.setup(baseURL:apiKey:…)` | `MapGlobalConfig.setMapGlobalConfig(MapViewConfig(apiKey))` |
| `VkMapsInitializerApi.isInitialized` | флаг на стороне плагина | флаг на стороне плагина |

## Создание карты

| Контракт | iOS | Android |
| --- | --- | --- |
| `initializeView` | `MapView(frame:configuration:delegate:)` с `MapConfiguration` | `MapView` из разметки, `getMapAsync` |
| `platformViewType` | не применяется | режим композиции platform view |

## Камера

| Контракт | iOS | Android |
| --- | --- | --- |
| `moveCamera` | `CameraController.flyTo(coordinates:cameraOptions:animationOptions:…)` | `Map.flyTo`, `setZoom`, `setBearing` |
| `fitBounds` | `CameraController.fitBounds(_:padding:animationDuration:…)` | нет; центрируемся на середине области |
| `getCameraPosition` | `centerCoordinates`, `zoom`, `bearing`, `pitch` | последнее известное состояние на стороне плагина |
| `getVisibleBounds` | `CameraController.mapBounds` | нет |
| `coordinateForScreenPoint` | `coordinatesByViewPoint(_:)` | нет |
| `screenPointForCoordinate` | нет обратной проекции | нет |

## Объекты

| Контракт | iOS | Android |
| --- | --- | --- |
| `updateMarkers` | `OverlayController.addMarker/removeMarker`, `Marker(id:coordinates:imageID:alignment:zIndex:)` | `Map.addMarker(MarkerEntity)`, `removeMarker(id)` |
| `addStyleImage` | `MapStyle.addImage(imageID:pngImageData:scale:)` | нет; картинка выбирается из перечисления SDK |
| `addGeoJsonSource` | `MapDataSource(id:json:type:.geojson:…)`, `MapStyle.addSource` | `GeojsonSource(id, ByteArray)` |
| `setGeoJsonSourceData` | `MapDataSource.setGeoJSON(_:)` | пересоздание источника |
| `addEncodedPolylineSource` | `MapDataSource(id:encodedString:…)` | `PolylineSource(id, String)` |
| `addLayer` | `MapLayer(json:)`, `MapStyle.addLayer/insertLayer(_:before:)` | `Map.addLayer(Layer)` — структура `Layer` не описана |
| `setLayerVisibility` | `MapLayer.isVisible` | нет |

## Стиль

| Контракт | iOS | Android |
| --- | --- | --- |
| `PlatformStyleKind.predefined` | `MapStyle(predefinedStyle:)`, `MapPredefinedStyle` | `MapStyle.Main/Dark/Simple` |
| `PlatformStyleKind.json` | `MapStyle(json:)` | нет |
| `PlatformStyleKind.url` | `MapStyle(url:)` | `MapStyle.Custom(url)` |

## Настройки карты

| Контракт | iOS | Android |
| --- | --- | --- |
| `compassEnabled` | `MapView.showsCompass` | `CompassView` в разметке приложения |
| `zoomButtonsEnabled` | `MapView.showsZoomButtons` | `ZoomView` в разметке приложения |
| `currentLocationButtonEnabled` | `MapView.isCurrentLocationButtonVisible` | `CurrentLocationView` в разметке |
| `scrollGesturesEnabled` | `isScrollGesturesEnabled` | `Map.enableDragPan` |
| `zoomGesturesEnabled` / `rotateGesturesEnabled` | `isZoomGesturesEnabled`, `isRotateGesturesEnabled` | `Map.enableZoomRotate` (общий флаг) |
| `logoAlignment`, `logoInsets`, `logoIgnoresSafeArea` | одноимённые свойства `MapView` | `LogoConfig` в `MapStartOptions` |
| `padding` | `CameraController.setPadding` | нет |
| `minZoom`, `maxZoom` | `CameraController.minZoom/maxZoom` | нет |

## Индикатор пользователя и режимы

| Контракт | iOS | Android |
| --- | --- | --- |
| `setUserLocation` | `UserPointerController.setCurrentLocation(…)`, `isVisible` | `Map.setLocationSource(LocationSource)` |
| `getMode` / `setMode` | `MapView.mode`, `setMode(_:)` | нет; режим меняется кнопкой |

## События

| Контракт | iOS | Android |
| --- | --- | --- |
| `mapShown` | `MapEvent.mapDidShow` | момент готовности `getMapAsync` |
| `tap` / `longTap` | `MapEvent.tap`, `MapEvent.longTap` | `setOnMapClickListener`, `setOnMapLongClickListener` |
| `markerTap` | `MapEvent.markerDidSelect` | `setOnMarkerClickListener` |
| `cameraMove` | `MapEvent.cameraDidMove(state:reason:phase:)` | `setOnZoomChangedListener` (только зум) |
| `styleApplied` | `MapEvent.styleDidApply` | нет |
| `modeChanged` | `mapView(_:didChangeModeTo:)` | нет |
| `lowMemory` | `MapEvent.lowMemoryWarning` | нет |
| `error` | `mapView(_:didFailWithError:)`, `tileDidFail`, `gpuError` | `addOnErrorListener` |

## Чего в контракте нет намеренно

`applyScenes`, `setDebugOption`, `preferLoad`, `setAntialiasing`,
`reduceMemoryUse`, `selectMapFeature`, работа с моделями и сценами
(`MapPin`, `MapPinNode`, mesh-анимации). Это либо отладочные средства, либо
трёхмерная сцена, которой нет на Android; выносить их наружу до появления
парного API нельзя — иначе Dart-API станет iOS-специфичным.
