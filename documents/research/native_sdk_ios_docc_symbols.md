
===== MapView ( Class )
Main object of the Map
DECL: @MainActor class MapView
## Overview
Add MapView to your hierarchy of views to display map on the screen.
TOPIC Initializers
    init(frame: CGRect) 
    init(frame: CGRect, configuration: MapConfiguration, delegate: (any MapViewDelegate)?) -- Create new MapView instance
TOPIC Instance Properties
    let camera: CameraController -- Controller to management camera on map
    var delegate: (any MapViewDelegate)? 
    var isCurrentLocationButtonVisible: Bool -- A Boolean value that determines visibility of the Current Location button
    var isRotateGesturesEnabled: Bool -- A Boolean value that indicates whether the user may use gestures to rotate the map
    var isScrollGesturesEnabled: Bool -- A Boolean value that determines whether the user may use gestures to move map
    var isZoomGesturesEnabled: Bool -- A Boolean value that determines whether the user may use gestures to zoom in and out of the map
    var logoAlignment: MapLogoAlignment -- Alignment of the logo
    var logoIgnoresSafeArea: Bool -- The Boolean value that determines ignoring logo of the safe area
    var logoInsets: MapEdgeInsets -- Insets of the logo
    var mode: MapMode -- Current mode of the Map
    let overlay: OverlayController -- Controller to management overlay on map, such as markers and shapes
    var showsCompass: Bool -- A Boolean value that determines visibility of the compass
    var showsZoomButtons: Bool -- A Boolean value that determines visibility of zoom buttons
    var style: MapStyle? -- Current style of the Map
    let userPointer: UserPointerController -- Controller to management user pointer on map
TOPIC Instance Methods
    func applyScenes(force: Bool) -- Apply all scenes (render scene and physical scene)
    func deselectMapFeature() -- Remove selection from map feature, selected by touch 
if `MapConfiguration.selectFeatures` equals  
to `.all` or `.drawSelection`,
or by call `func selectMapFeature(refId: String)`
    func disablePreferLoad(source: String) -- Disable forcing endpoints of a vector tile source to be used as a primary endpoint to load tiles.
    func getDebugOption(String) -> String 
    func onTapCurrentLocationButton() -- Call this method to simulate tap on Current Location button
    func preferLoad(source: String, endpoint: Int) -- Force a specific endpoint of a vector tile source to be used as a primary endpoint to load tiles.
    func reduceMemoryUse() -- Initiate internal memory cleanup process to reduce memory usage.
    func selectMapFeature(sourceId: String, refId: String) -- Selecting a feature, the same as if it were selected by touching it 
when the setting `MapConfiguration.selectFeatures` 
equals  to `.all` or `.drawSelection`
    func setAntialiasing(antialiasing: MapAntialiasing, shouldPickMaxAvailableSamples: Bool) -- Sets antialiasing
    func setDebugOption(String, String) 
    func setMode(MapMode) -- Sets the mode of the Map
    func setPresentWithTransactionIfNotSupports(gpuFamily: MTLGPUFamily) -- If MTLDevice supports features of a specific family, the presentWithTransactions feature will not be enabled for PlatformMarker.
    func setStyle(MapStyle, force: Bool) -- Set style of the Map
    func viewDidMoveToSuperview() 
TOPIC Type Properties
    static var groupOffsetId: Int 
    static var pinOffsetId: Int 
TOPIC Default Implementations
    OpaquePointerConvertable-Implementations 

===== MapConfiguration ( Structure )
Configuration of Map
DECL: struct MapConfiguration
## Overview
Use the configuration to initially set up the map, as well as determine the parameters for loading tiles
TOPIC Initializers
    init(center: Coordinates, zoom: Double, pitch: Angle, maxPitch: Angle, bearing: Angle, customStyle: String, fonts: [String], selectFeatures: FeaturesSelectionMode, cameraMode: MapConfiguration.CameraMode) -- Map configuration with custom style
    init(center: Coordinates, zoom: Double, pitch: Angle, maxPitch: Angle, bearing: Angle, predefinedStyle: MapPredefinedStyle, fonts: [String], selectFeatures: FeaturesSelectionMode, cameraMode: MapConfiguration.CameraMode) -- Map configuration with predefined style
    init(center: Coordinates, zoom: Double, pitch: Angle, maxPitch: Angle, bearing: Angle, remoteStyleURL: URL, fonts: [String], selectFeatures: FeaturesSelectionMode, cameraMode: MapConfiguration.CameraMode) -- Map configuration with loading style from url
    init(center: Coordinates, zoom: Double, pitch: Angle, maxPitch: Angle, bearing: Angle, style: MapStyle, fonts: [String], selectFeatures: FeaturesSelectionMode, cameraMode: MapConfiguration.CameraMode) -- Map configuration with style instance
TOPIC Instance Properties
    let bearing: Angle 
    let cameraMode: MapConfiguration.CameraMode 
    let center: Coordinates 
    let fonts: [String] 
    let maxPitch: Angle 
    let pitch: Angle 
    let selectFeatures: FeaturesSelectionMode 
    let style: MapConfiguration.Style 
    let zoom: Double 
TOPIC Enumerations
    enum CameraMode 
    enum Style 

===== MapViewDelegate ( Protocol )
Interface, that MapView uses to inform its delegate about events on map
DECL: @MainActor protocol MapViewDelegate : AnyObject
TOPIC Instance Methods
    func mapView(MapView, didChangeModeTo: MapMode) -- Tells the delegate that mode of mapView did change
    func mapView(MapView, didFailWithError: any Error) -- Tells the delegate that some error was throwed
    func mapView(MapView, didReceiveEvent: MapEvent) -- Tells the delegate that the mapView did receive a new event
    func mapView(MapView, willChangeModeTo: MapMode) -> MapMode -- Tells the delegate that mode of mapView will change. Use current method to edit logic of mode changing, such as remove some modes.

===== MapsSDKConfigurator ( Enumeration )
Configurator of SDK
DECL: enum MapsSDKConfigurator
TOPIC Type Methods
    static func addCustomHeaders([String : String]) -- Adds headers into NetworkServiceV3 requests
    static func cacheInfo(type: DiskCacheType) -> DiskCacheInfo 
    static func clearCache(type: DiskCacheType) -> DiskCacheType -- Clear cache of specific type
    static func loadTilesToTileCache(style: MapStyle, northEast: Coordinates, southWest: Coordinates, zoom: Double) -- Load tiles from tiled sources of the supplied style within specified geographic bounds
    static func setup(baseURL: String, apiKey: String, tileCacheOptions: DiskCacheOptions?, modelCacheOptions: DiskCacheOptions?, commonCacheOptions: DiskCacheOptions?, tileReloadIntervals: [UInt64], styleLoadTimeout: UInt64, tileLoadTimeout: UInt64, sourceLoadTimeout: UInt64, geoJsonLoadTimeout: UInt64, dataLoadTimeout: UInt64, overrideURLSessionConfiguration: URLSessionConfiguration?, resourceBundle: Bundle?) -> Bool -- Configurate SDK to using the specific URL for loading tyles and predefined styles, API-key and file cahce properties.

===== MapStyle ( Structure )
Controller for managing map style: sources, layers, and runtime images/models.
DECL: struct MapStyle
TOPIC Operators
    static func == (MapStyle, MapStyle) -> Bool 
TOPIC Initializers
    init() -- Creates an empty style.
    init?(from: MapView) -- Get style from MapView instance
    init(json: String) async throws -- Initializes a style from a JSON string.
    init(predefinedStyle: MapPredefinedStyle) async throws -- Initializes a predefined SDK style.
    init(url: URL) async throws -- Initializes a style from a JSON URL.
TOPIC Instance Properties
    var currentLocationColors: CurrentLocationColors -- The colors used for the geolocation marker.
    var currentLocationImage: String? -- The name of the image used for the geolocation marker, if any.
    var currentLocationModel: CurrentLocationModel? -- The model parameters of the geolocation marker, if any.
    var layers: [MapLayer] -- The layers of the style.
    var name: String -- The name of the style.
    var sources: [MapDataSource] -- The sources of the style.
TOPIC Instance Methods
    func addCGContext(imageID: String, context: CGContext, scale: CGFloat) throws -- Adds a bitmap from a CGContext to runtime images.
    func addImage(imageID: String, image: CGImage, scale: CGFloat) throws -- Adds an image to runtime textures via CGImage.
    func addImage(imageID: String, mapImage: MapImage, scale: CGFloat) throws -- Adds an image to runtime images via MapImage.
    func addImage(imageID: String, pngImageData: Data, scale: CGFloat) throws -- Adds a PNG image to runtime images.
    func addImage(imageID: String, scale: CGFloat, () -> MapImage) throws -- Adds an image to runtime images using a closure that returns a MapImage.
    func addImage(imageID: String, svgData: String, scale: CGFloat, size: CGSize) throws -- Adds an SVG image to runtime images.
    func addLayer(MapLayer) throws -- Adds a layer to the style.
    func addModel(modelID: String, data: Data) -- Adds a model to the style.
    func addRawRGBABitmap(imageID: String, bitmap: UnsafeRawPointer!, width: UInt32, height: UInt32, scale: CGFloat) throws -- Adds an RGBA bitmap from a raw byte array to runtime images.
    func addSource(MapDataSource) throws -- Adds a source to the style.
    func addSources([MapDataSource], andLayers: [MapLayer]) throws -- Adds multiple sources and layers to the style.
    func addVectorImage(imageID: String, cgPath: CGPath, scale: CGFloat, drawingMode: CGPathDrawingMode, fillColor: CGColor?, strokeColor: CGColor?) throws -- Add bitmap from vector image to runtime images.
    func hasImage(imageID: String) -> Bool -- Checks if runtime images contain the specified image.
    func hasModel(modelID: String) -> Bool -- Checks if the style contains the specified model.
    func insertLayer(MapLayer, after: String) throws -- Inserts a layer after the specified layer ID.
    func insertLayer(MapLayer, at: Int) throws -- Inserts a layer at the given position.
    func insertLayer(MapLayer, before: String) throws -- Inserts a layer before the specified layer ID.
    func layer(at: Int) -> MapLayer? -- Returns the layer at the given index.
    func layer(by: String) -> MapLayer? -- Returns the layer with the given ID.
    func removeCurrentLocationImage() -- Removes the image as the user’s geolocation marker.
    func removeCurrentLocationModel() -- Removes the model as the user’s geolocation marker.
    func removeImage(imageID: String) -- Removes an image from runtime images.
    func removeLayer(MapLayer) -- Removes a layer from the style.
    func removeLayer(by: String) -- Removes a layer from the style by ID.
    func removeModel(modelID: String) -- Removes a model from the style.
    func removeSource(MapDataSource) -- Removes a source from the style.
    func removeSource(by: String) -- Removes a source from the style by ID.
    func removeSprite(key: String) throws -- Destroy sprite from memory
    func setCurrentLocationColors(colors: CurrentLocationColors) -- Sets the colors of different parts of the user’s geolocation marker.
    func setCurrentLocationImage(iconID: String) -- Sets the image as the user’s geolocation marker.
    func setCurrentLocationModel(model: CurrentLocationModel) -- Sets the model as the user’s geolocation marker.
    func setSprite(data: Data, metaData: String, key: String) throws -- Append or replace to style a new sprite.
A sprite’s image file is a PNG image containing the sprite data.
    func setSprite(url: URL, key: String) throws -- Append or replace to style a new sprite.
A sprite’s image file is a PNG image containing the sprite data.
    func source(at: Int) -> MapDataSource? -- Returns the source at the given index.
    func source(by: String) -> MapDataSource? -- Returns the source with the given ID.
TOPIC Default Implementations
    Equatable-Implementations 

===== MapPredefinedStyle ( Enumeration )

DECL: enum MapPredefinedStyle
TOPIC Enumeration Cases
    case dark 
    case grayLight 
    case main 
    case navigationDark 
    case navigationMain 
    case simple 
    case simpleDark 
TOPIC Initializers
    init?(rawValue: String) 
TOPIC Default Implementations
    Equatable-Implementations 
    RawRepresentable-Implementations 

===== Marker ( Structure )

DECL: struct Marker
TOPIC Initializers
    init(id: UInt32, coordinates: Coordinates, imageID: String, alignment: MarkerImageAlignment, zIndex: Int32) 
TOPIC Instance Properties
    let alignment: MarkerImageAlignment 
    let coordinates: Coordinates 
    let id: UInt32 
    let imageID: String 
    let zIndex: Int32 

===== MapPin ( Class )

DECL: class MapPin
TOPIC Initializers
    init(String) 
    init(String, coordinates: Coordinates) 
    init(String, coordinates: Coordinates, node: any MapBaseNode) 
TOPIC Instance Properties
    var altitudeMeters: Double 
    var coordinates: Coordinates 
    var id: String 
    var node: MapPinNode? 
    let storage: MapObjectStorage 
TOPIC Instance Methods
    func setAltitudeMetersAnimated(Double, duration: TimeInterval, easing: MapAnimationEasing) 
    func setCoordinatesAnimated(coordinates: Coordinates, duration: TimeInterval, easing: MapAnimationEasing) 
    func setInWorldSpace(Bool) 
    func setLayer(UInt8, propagateToChildren: Bool) 
    func setOverlay(any MapBaseNode) 

===== MapCameraOptions ( Structure )
State of camera, inlcude bearing, zoom, pitch and padding
DECL: struct MapCameraOptions
TOPIC Initializers
    init(bearing: Double?, zoom: Double?, pitch: Double?, padding: MapEdgeInsets?) -- Create object, which describes properties of camera.
    init(from: any Decoder) throws 
TOPIC Instance Properties
    var bearing: Double? 
    var padding: MapEdgeInsets? 
    var pitch: Double? 
    var zoom: Double? 

===== MapFlyToOptions ( Structure )

DECL: struct MapFlyToOptions
TOPIC Initializers
    init(zoomingIndex: MapViewAnimationZoomingIndex, zooming: MapViewFlyToOptionsZooming, duration: Duration?) 
TOPIC Instance Properties
    var duration: Duration? 
    var zooming: MapViewFlyToOptionsZooming 
    var zoomingIndex: MapViewAnimationZoomingIndex 

===== MapEvent ( Enumeration )
Event of the MapView
DECL: enum MapEvent
## Overview
Events are used to notify the MapViewDelegate of various map changes or events that have occurred, including lifecycle stages, styles loading, map and marker taps, etc.
TOPIC Structures
    struct CameraPosition -- Describes the position of camera
    struct EventCoordinates 
    struct FeatureDetails 
TOPIC Enumeration Cases
    case cameraDidMove(state: MapEvent.CameraPosition, reason: MapEvent.CameraMovingReason, phase: MapEvent.CameraMovingPhase) -- Camera did move to new position
    case collision(nodeId0: String, nodeId1: String, impulse: Double) -- Physics collision detected between two nodes
    case featureDidSelect(details: MapEvent.FeatureDetails) 
    case gpuError 
    case longTap(coordinates: MapEvent.EventCoordinates) -- User did long tap on the Map
    case lowMemoryWarning 
    case mapDidShow -- MapView did show the Map on the screen
    case markerDidSelect(id: UInt32, coordinates: MapEvent.EventCoordinates) 
    case meshAnimation(nodeId: String, animationName: String, animationIndex: Int, count: Int) -- Mesh animation is played
    case nodeDidSelect(pin: MapPin, node: MapPinNode, tapOffsetInNode: CGVector, tapUiCoordinates: CGPoint, isLongtap: Bool) -- Tap selected a scene node belonging to a pin
    case platformMarkerDidSelect(id: String) 
    case styleDidApply -- MapView did successful new style apply
    case styleDidSet -- MapView did set new style
    case styleDidUpdate -- MapView did update current style
    case tap(coordinates: MapEvent.EventCoordinates) -- User did tap on the Map
    case tileDidFail(tileId: MapTileId, message: String) 
    case tileDidFailLoad(tileId: MapTileId, message: String) 
TOPIC Enumerations
    enum CameraMovingPhase -- Phase of camera moving
    enum CameraMovingReason -- Reason of camera moving
    enum Control 
    enum GestureType 

===== MapError ( Enumeration )

DECL: enum MapError
TOPIC Enumeration Cases
    case cancelled(message: String) 
    case currentPositionNotSet 
    case invalidArgument(message: String) 
    case invalidLayer(message: String) 
    case invalidSource(message: String) 
    case invalidState(message: String) 
    case invalidStyle(message: String) 
TOPIC Instance Properties
    var description: String 
    var errorDescription: String? 
TOPIC Default Implementations
    Error-Implementations 
    LocalizedError-Implementations 

===== MapMode ( Enumeration )
Mode of the Map
DECL: enum MapMode
## Overview
Use this value to set and determine the Map’s mode.
- The `.free` mode allows you to freely move the map without being tied to the marker of the user’s current position on the Map.
- The `.followLocation` mode fixes the center of the Map (taking into setted paddings) on the user’s marker.
- The `.followBearingAndLocation` additionally changes the rotation angle of the Map according to the direction of the user’s marker.
TOPIC Enumeration Cases
    case followBearingAndLocation 
    case followLocation 
    case free 
TOPIC Default Implementations
    Equatable-Implementations 

===== MapDataSource ( Class )

DECL: final class MapDataSource
TOPIC Initializers
    init(id: String, encodedString: String, type: MapDataSourceType, receiveTapEvents: Bool) throws 
    init(id: String, json: String, type: MapDataSourceType, receiveTapEvents: Bool) throws 
    init(id: String, jsonData: Data, type: MapDataSourceType, receiveTapEvents: Bool) throws 
    convenience init(id: String, vectorSource: VectorSourceConfiguration, receiveTapEvents: Bool) throws 
TOPIC Instance Properties
    var id: String 
    var type: MapDataSourceType 
TOPIC Instance Methods
    func getTileURLs(for: MapTileId) -> [URL] -- Get tile URLs for the specified tile coordinates
    func setData(geoJSON: String) 
    func setData(url: URL) 
    func setEncodedPolyline(String) 
    func setGeoJSON(String) 
    func setReceiveTapEvents(Bool) 
TOPIC Default Implementations
    Equatable-Implementations 

===== MapDataSourceType ( Enumeration )

DECL: enum MapDataSourceType
TOPIC Enumeration Cases
    case geoJSON 
    case vector 
TOPIC Initializers
    init?(rawValue: Int) 
TOPIC Default Implementations
    Equatable-Implementations 
    RawRepresentable-Implementations 

===== MapLayer ( Class )

DECL: final class MapLayer
TOPIC Initializers
    init(id: String, sourceID: String, paint: any PaintProperties, layout: LayoutProperties) throws 
    init(json: String) throws 
TOPIC Instance Properties
    var id: String 
    var isVisible: Bool 
TOPIC Default Implementations
    Equatable-Implementations 

===== LinePaintProperties ( Structure )

DECL: struct LinePaintProperties
TOPIC Initializers
    init(lineColor: PaintColor, lineWidth: Double, lineOpacity: PaintOpacity, lineOcclusionOpacity: PaintOpacity?, dashes: LineDashes?) 
TOPIC Instance Properties
    let dashes: LineDashes? 
    let lineColor: PaintColor 
    let lineOcclusionOpacity: PaintOpacity? 
    let lineOpacity: PaintOpacity 
    let lineWidth: Double 
    let type: RenderingType 
TOPIC Default Implementations
    PaintProperties-Implementations 

===== FillPaintProperties ( Structure )

DECL: struct FillPaintProperties
TOPIC Initializers
    init(fillColor: PaintColor, fillOpacity: PaintOpacity) 
TOPIC Instance Properties
    let fillColor: PaintColor 
    let fillOpacity: PaintOpacity 
    let type: RenderingType 
TOPIC Default Implementations
    PaintProperties-Implementations 

===== CameraController ( Class )
Controller of map camera
DECL: @MainActor final class CameraController
## Overview
Use current controller to change camera settings, such as camera bearing, pitch, zoom an others
TOPIC Structures
    struct DecelerationRate 
TOPIC Instance Properties
    var altitudeMeters: Double -- Current altitude of camera in meters
    var bearing: Double -- Get current camera bearing in degrees, measured in degrees clockwise from north.
    var bearingInertiaRate: Angle -- Deceleration rate for bearing inertia
    var centerCoordinates: Coordinates -- Coordinates of the Maps’s center
    var mapBounds: MapBounds -- Geographic bounds of the Map.
    var maxZoom: Double -- Current max zoom of camera
    var minZoom: Double -- Current min zoom of camera
    var pitch: Double -- Get current camera angle of pitch in degrees
    var scrollInertiaRate: CameraController.DecelerationRate -- Deceleration rate for scroll inertia
    var zoom: Double -- Current zoom of camera
    var zoomInertiaRate: Double -- Deceleration rate for zoom inertia
TOPIC Instance Methods
    func altitudeMetersByZoom(Double) -> Double 
    func calculateAnimationDuration(coordinates: MapCameraCoordinates?, cameraOptions: MapCameraOptions?, animationOptions: MapAnimationOptions) -> TimeInterval -- Calculate duration of animation. Camera will NOT change - the passed parameters determine the end state of the animation, but the animation itself will be discarded. This method can be useful to determine how long will it take for the camera to fly to a destination.
    func calculateBoundingBox(coordinates: MapCameraCoordinates, cameraOptions: MapCameraOptions) -> MapBounds -- Calculate geographic bounds of the Map without affecting camera position.
    func coordinatesByViewPoint(CGPoint) -> Coordinates? -- Get coordinates by point on the screen
    func coordinatesByViewPoints([CGPoint]) -> [Coordinates?] -- Get coordinates by points on the screen
    func easeTo(coordinates: MapCameraCoordinates?, cameraOptions: MapCameraOptions?, animationOptions: MapAnimationOptions?, reason: Any?, resetFollowingMode: Bool) async -> MapCameraAnimationResult -- Move camera to a new position
    func easeTo(coordinates: MapCameraCoordinates?, cameraOptions: MapCameraOptions?, animationOptions: MapAnimationOptions?, reason: Any?, resetFollowingMode: Bool, completion: ((MapCameraAnimationResult) -> Void)?) -- Move camera to a new position
    func featuresInRect(rect: CameraController.RectangleDimensions, layer: String) -> [MapFeature] 
    func featuresInRectAsync(rect: CameraController.RectangleDimensions, layers: [String], callback: (Result<[MapFeature], MapError>) -> Void) 
    func featuresWithPropertiesInRectAsync(rect: CameraController.RectangleDimensions, layers: [String], callback: (Result<[MapFeatureWithProperties], MapError>) -> Void) 
    func fitBounds(MapBounds, padding: MapEdgeInsets, animationDuration: TimeInterval, reason: Any?, completion: ((MapCameraAnimationResult) -> Void)?) -- Fit bounds into the Map
    func flyTo(coordinates: MapCameraCoordinates?, cameraOptions: MapCameraOptions?, animationOptions: MapAnimationOptions, reason: Any?, resetFollowingMode: Bool) async -> MapCameraAnimationResult -- Move camera to new position
    func flyTo(coordinates: MapCameraCoordinates?, cameraOptions: MapCameraOptions?, animationOptions: MapAnimationOptions?, reason: Any?, resetFollowingMode: Bool, completion: ((MapCameraAnimationResult) -> Void)?) -- Move camera to new position
    func flyTo(coordinates: MapCameraCoordinates?, cameraOptions: MapCameraOptions?, flyToOptions: MapFlyToOptions?, reason: Any?, resetFollowingMode: Bool) async -> MapCameraAnimationResult -- Move camera to a new position
    func flyTo(coordinates: MapCameraCoordinates?, cameraOptions: MapCameraOptions?, flyToOptions: MapFlyToOptions?, reason: Any?, resetFollowingMode: Bool, completion: ((MapCameraAnimationResult) -> Void)?) -- Move camera to a new position
    func flyToCurrentLocation(zoomLevel: Double?, animationOptions: MapAnimationOptions?, reason: Any?, resetFollowingMode: Bool) async -> MapCameraAnimationResult -- Move camera to user current location
    func flyToCurrentLocation(zoomLevel: Double?, animationOptions: MapAnimationOptions?, reason: Any?, resetFollowingMode: Bool, completion: ((MapCameraAnimationResult) -> Void)?) -- Move camera to user current location
    func getPadding() -> MapEdgeInsets 
    func limitBoundingBox(limitingStrategy: MapBoundsLimitingStrategy) -- Limit camera with the specified strategy, set camera center to the center of the passed bounding box.
    func limitedBoundingBox() -> MapBounds? -- Get current limiting bounding box for the camera.
    func metersPerPoint(zoom: Double, coordinates: Coordinates) -> Double -- Ratio of meters to points.
    func pointsPerMeter(zoom: Double, coordinates: Coordinates) -> Double -- Ratio of points to meters.
    func setBearing(degrees: Double, animationDuration: TimeInterval, reason: Any?) -- Set camera bearing in degrees.
    func setPadding(MapEdgeInsets, animationDuration: TimeInterval, reason: Any?) -- Set padding of the map.
    func setPitch(degrees: Double, animationDuration: TimeInterval, reason: Any?) -- Set camera angle of pitch in degrees
    func setPitchRange(minPitchDegrees: Double?, maxPitchDegrees: Double?) -- Set a range of allowed values of pitch in degrees
    func setZoom(Double, anchor: CGPoint?, animationDuration: TimeInterval, reason: Any?) -- Set level of zoom
    func setZoomRange(minZoom: Double?, maxZoom: Double?) -- Set a range of allowed values of zoom
    func stopAnimation() -- Stop current camera’s animation
    func viewPointByCoordinates(Coordinates) -> CGPoint? -- Get point on the screen by coordinates, or nil if not visible or outside of viewport
    func viewPointsByCoordinates([Coordinates]) -> [(position: CGPoint, opacity: Double)] -- Get points on the screen by coordinates array that fit in viewport
    func zoomByAltitudeMeters(Double) -> Double 
    func zoomIn(step: Double, animationDuration: TimeInterval, reason: Any?) -- Increase the zoom level by a value
    func zoomOut(step: Double, animationDuration: TimeInterval, reason: Any?) -- Decrease the zoom level by a value
TOPIC Enumerations
    enum RectangleDimensions 

===== DiskCacheOptions ( Structure )

DECL: struct DiskCacheOptions
TOPIC Initializers
    init(diskCachePath: String, maxCacheSizeBytes: UInt64, cacheFileTTLSec: UInt64) -- Create disk cache parameters
TOPIC Instance Properties
    let cacheFileTTLSec: UInt64 
    let diskCachePath: String 
    let maxCacheSizeBytes: UInt64 

===== MapBounds ( Structure )

DECL: struct MapBounds
TOPIC Initializers
    init(from: any Decoder) throws 
    init(southwest: Coordinates, northeast: Coordinates) 
TOPIC Instance Properties
    let northeast: Coordinates 
    let southwest: Coordinates 
TOPIC Default Implementations
    Equatable-Implementations 

===== Coordinates ( Structure )

DECL: struct Coordinates
TOPIC Initializers
    init(from: any Decoder) throws 
    init(lng: Double, lat: Double) 
TOPIC Instance Properties
    let lat: Double 
    let lng: Double 
TOPIC Default Implementations
    Equatable-Implementations 

===== OverlayController ( Class )
Controller of the Map’s overlay
DECL: @MainActor final class OverlayController
## Overview
Use current controller to control markers
TOPIC Instance Properties
    var scene: MapScene! 
TOPIC Instance Methods
    func addMarker(Marker) -- Add marker
    func removeAllMarkers() -- Remove markers
    func removeMarker(id: UInt32) -- Remove marker

===== UserPointerController ( Class )

DECL: @MainActor final class UserPointerController
TOPIC Instance Properties
    var accuracy: Double? -- Current accuracy in meters of the user pointer position
    var bearing: Double? -- Current bearing in degrees of the user pointer
    var coordinates: Coordinates? -- Current coordinates of the user pointer
    var isVisible: Bool -- Set visibility of the user pointer
TOPIC Instance Methods
    func setCurrentLocation(bearing: Double?, animationDuration: Double?) -- Set bearing of the user pointer.
    func setCurrentLocation(coordinates: Coordinates?, accuracy: Double?, animationDuration: Double?) -- Set coordinates and accuracy of the user pointer
    func setCurrentLocation(coordinates: Coordinates?, bearing: Double?, accuracy: Double?, animationDuration: Double?) -- Set coordinates, bearing and accuracy of the user pointer.
