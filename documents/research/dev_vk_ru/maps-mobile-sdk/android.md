<!-- Источник: https://dev.vk.ru/ru/vkmaps/maps-mobile-sdk/android -->
<!-- Снято: 2026-09-08 -->

# Maps SDK для Android

**Mobile Maps SDK** позволяет добавить карту в ваше Android приложение.

## Подключение

Для подключения Maps SDK необходимо добавить в главный `gradle` файл проекта ссылку на `maven` репозиторий.

### Пример кода gradle файла с ссылкой на `maven` репозиторий

```gradle
allprojects {
 repositories {
        maven {
            url 'https://artifactory-external.vkpartner.ru/artifactory/maps-sdk-android/'
} } }
```

Также в `gradle` файле модуля, использующего SDK, необходимо прописать зависимость, как показано в примере.

### Пример добавления зависимостей

```gradle
implementation('ru.mail.maps:mapkit:x.x.x')
```

где `x.x.x` — версия SDK.

Рекомендуется использовать самую свежую версию SDK. Релизные версии SDK имеют нумерацию 1.0.x
Последнюю версию SDK можно найти по адресу: [https://artifactory-external.vkpartner.ru/artifactory/maps-sdk-android/ru/mail/maps/mapkit/](https://vk.ru/away.php?to=https%3A%2F%2Fartifactory-external.vkpartner.ru%2Fartifactory%2Fmaps-sdk-android%2Fru%2Fmail%2Fmaps%2Fmapkit%2F)

## Использование

Необходимо инициализировать глобальные настройки карты до использования других компонентов SDK. Лучший вариант — в наследнике класса `Application`.

### Пример объекта глобальных настроек

```kotlin
class MapViewConfig(
 val apiKey: String, // уникальный ключ для предоставления доступа к работе с SDK
)
```

Установить его нужно следующим образом, как показано в примере.

### Пример установки

```kotlin
MapGlobalConfig.setMapGlobalConfig(
            MapViewConfig(
                apiKey = apiKey
        )
)
```

### Пример объекта MapStartOptions

```kotlin
data class MapStartOptions(
 val center: LatLon, // точка начального расположения карты (учитываются только lat, lon)
 val zoomLevel: Float, // начальное значение уровня масштабирования (zoomLevel)
 val style: MapStyle, // стиль карты, может быть выбран из соответствующего enum или использован свой
 val compassLocationMode: CompassLocationMode, // настройка компаса, может быть выбран из соответствующего enum
 val logoConfig: LogoConfig // конфигурация логотипа
)
```

Установить стартовые настройки нужно как показано в примере.

### Пример установки

```kotlin
MapGlobalConfig.setMapStartOptions(MapStartOptions(...))
```

### Пример объекта LogoConfig

```kotlin
data class LogoConfig(
 val logoAlignment: Alignment, // выравнивание логотипа, может быть выбран из четырех возможных вариантов Alignment: BottomRight, BottomLeft, TopRight, TopLeft
 val logoAdditionalPaddings: AdditionalPaddings // дополнительные паддинги, с помощью которого можно задать горизонтальные и вертикальные отступы
)
```

Для работы с SDK предусмотрен ряд классов, реализующих в той или иной форме `View`:

- `MapView` — является основным представлением в SDK, которое отображает карту;
- `ZoomView` — используется для отображения контролов `+` и `-`, которые можно использовать для приближения и отдаления карты;
- `CurrentLocationView` — кнопка для фокусировки карты на текущей позиции пользователя и следования за его положением;
- `CompassView` — компонент, отображающий направление физического устройства относительно севера.

Для отображения данных элементов управления необходимо разместить их в xml-файле разметки страницы.

### Пример отображения карты

```xml
<FrameLayout
 android:id="@+id/mainLayout"
 android:layout_width="match_parent"
 android:layout_height="match_parent"
 ...>

 <ru.mail.maps.sdk.views.MapView
 android:id="@+id/mapView"
 android:layout_width="match_parent"
 android:layout_height="match_parent" />
</FrameLayout>
```

Этого может быть достаточно для работы с картой, если остальные элементы управления не требуются. В противном случае необходимо разместить другие элементы управления в том же самом `layout`, в котором находится карта. В примере выше это `mainLayout`. Также необходимо прописать ссылку на карту для каждого из контролов.

### Пример с контролами

```xml
<FrameLayout
 xmlns:custom="http://schemas.android.com/apk/res-auto"
 android:id="@+id/mainLayout"
 android:layout_width="match_parent"
 android:layout_height="match_parent"
 ...>

 <ru.mail.maps.sdk.views.MapView
 android:id="@+id/mapView"
 android:layout_width="match_parent"
 android:layout_height="match_parent" />

 <ru.mail.maps.sdk.views.ZoomView
 android:id="@+id/zoomView"
 android:layout_width="wrap_content"
 android:layout_height="wrap_content"
 ...
 custom:mapView="@+id/mapView" />

 <ru.mail.maps.sdk.views.CompassView
 android:layout_width="wrap_content"
 android:layout_height="wrap_content"
 ...
 custom:mapView="@+id/mapView" />

 <ru.mail.maps.sdk.views.CurrentLocationView
 android:layout_width="wrap_content"
 android:layout_height="wrap_content"
 ...
 custom:mapView="@+id/mapView"/>
</FrameLayout>
```

Таким образом все элементы управления будут отображаться поверх карты и будут иметь привязку к ней. Чтобы напрямую вызывать методы карты, необходимо получить сущность `Map` — вызвать метод `getMapAsync` у визуального контрола карты.

### Пример прямого вызова метода карты

```kotlin
mapView = findViewById(R.id.mapView)
mapView.getMapAsync { map -> // тот самый объект Map
    ...
}
```

Для корректной работы контролов `CurrentLocationView` и `CompassView` необходимо передать в объект `Map` реализацию интерфейса `LocationSource`, например.

### Пример передачи в объект Map реализации интерфейса LocationSource

```kotlin
map.setLocationSource(locationSource)
```

### Методы интерфейса `LocationSource`

```kotlin
fun activate(listener: (mapLocation: MapLocation) -> Unit) // используется для старта процесса получения gps фиксов от системы
fun deactivate() // вызывается при необходимости остановить получение gps данных
```

SDK самостоятельно вызывает методы `activate` и `deactivate`, когда это необходимо (согласно внутренней логике). При вызове `activate` в качестве параметра передается `listener`, который необходимо вызывать при получении каждого нового gps-фикса с аргументом типа `MapLocation`.

### Пример

```kotlin
data class MapLocation(
 val latitude: Double? = null, // широта [-90, 90]
 val longitude: Double? = null, // долгота [-180, 180]
 val speed: Float? = null, // скорость
 val bearing: Float? = null, // направление [0, 360]
 val accuracy: Float? = null, // точность
 val altitude: Double? = null // высота над уровнем моря в метрах
)
```

Каждое из полей класса может быть `null`, но для корректной работы необходимо подставлять соответствующие значения, полученные от системы. Помимо метода `setLocationSource` у объекта `Map` есть следующие.

### Примеры методов объекта Map

```kotlin
// Изменить координаты центра карты
// За анимацию изменений отвечает аргумент animated, за длительность - duration, а за кривую движения камеры - cameraCurve.
// Указание длительности анимации и кривой движения камеры опционально
fun flyTo(mapLocation: MapLocation, animated: Boolean, durationMs: Int?, cameraCurve: CameraCurve = CameraCurve.Standard()) 

// Увеличить карту, step — значение шага, на который будет увеличена карта
fun zoomIn(step: Float = .5f, animated: Boolean = true)

// Уменьшить карту, step — значение шага, на который будет уменьшена карта
fun zoomOut(step: Float = .5f, animated: Boolean = true)

// Выставляет направление карты, bearing лежит в полуинтервале [0, 360)
fun setBearing(bearing: Float, animated: Boolean = true)

// Выставляет уровень масштаба карты, zoom лежит в полуинтервале (0, 20]
fun setZoom(zoom: Float, animated: Boolean = true)

// Добавляет маркер на карту, где MarkerEntity — модель маркера, id — уникальный для каждого маркера идентификатор, coordinates — координаты точки, к которой будет привязан маркер (учитывается только latitude и longitude, остальные null) и image — одно из значений enum MarkerImage
fun addMarker(marker: MarkerEntity)

// Добавить список маркеров на карту
fun addMarker(markers: List<MarkerEntity>)

// Удалить маркер с указанным идентификатором
fun removeMarker(id: String)

// Удалить все маркеры с карты
fun removeAllMarkers()

// Показать PopUp окно над маркером, markerId — идентификатор маркера, к которому будет привязано окно; content — HTML-строка, текст которой будет отображен в окне
fun showPopUp(markerId: String, content: String)

// Скрыть PopUp окно для соответствующего идентификатору маркера
fun hidePopUp(markerId: String)

// Добавить метод-callback, который будет вызван, когда пользователь сделает клик на один из маркеров id — идентификатор маркера, на который кликнул пользователь, location — координаты, которые соответствуют маркеру (учитывается только latitude и longitude, остальные null)
fun setOnMarkerClickListener(onCLickListener: (id: String, location: MapLocation) -> Unit)

// Удалить метод-callback, отвечающий за клик по маркеру
fun removeMarkerClickListener()

// Задать перемещение маркеру с соответствующим id в позицию location. animated — необходима ли анимация перемещения маркера duration — длительность анимации перемещения
fun moveMarker(id: String, location: MapLocation, animated: Boolean, duration: Double)

// Добавить коллбэк, который будет вызываться в случае возникновения тех или иных ошибок в сдк. Все ошибки являются наследниками класса MapError
fun addOnErrorListener(onErrorListener: (error: MapError) -> Unit)

// Переместить карту, чтобы центр экрана совпадал с параметром center (учитывается только latitude и longitude, остальные null)
fun setCenter(center: MapLocation, animated: Boolean)

// Изменить стиль карты без необходимости переинициализации
fun changeStyle(style: MapStyle)

// Разрешить или запретить управление картой жестами
fun enableDragPan(enable: Boolean)

// Разрешить или запретить изменение масштаба карты и вращение пользователем
fun enableZoomRotate(enable: Boolean)

// Установить метод-коллбэк, который будет вызван при изменении масштаба карты
fun setOnZoomChangedListener(listener: (zoom: Double) -> Unit)

// Удалить метод-коллбэк, отвечающий за изменение масштаба карты
fun removeZoomChangedListener()

// Установить метод-коллбэк, отвечающий за событие клика по карте
fun setOnMapClickListener(onClickListener: (location: MapLocation, screenLocation: ScreenLocation) -> Unit)

 // Установить метод-коллбэк, отвечающий за событие длительного клика по карте
fun setOnMapLongClickListener(onClickListener: (location: MapLocation, screenLocation: ScreenLocation) -> Unit)

 // Добавить новый слой на карту
fun addLayer(layer: Layer)

// Добавить новый источник данных для карты
fun addMapDataSource(source: MapDataSource)

// Удалить источник данных по id
fun removeSource(sourceId: String)

// Удалить слой с карты по id
fun removeLayer(layerId: String)

// Добавить кластер на карту, где в объекте Cluster содержатся: id — идентификатор кластера, markers — список объектов маркеров, radius — радиус кластера в метрах, textColor — цвет текста в hex ("#ff0000"), backgroundColor — цвет фона в hex ("#ffffff")
fun addCluster(cluster: Cluster)

// Удалить кластер по идентификатору
fun removeCluster(id: String)
```

С помощью этих методов можно вручную управлять картой, независимо от предоставленных SDK контролов. Все методы SDK необходимо вызывать в `main` потоке. Коллбеки также возвращаются в `main` поток.

Для использования метода `addMapDataSource` необходимо создать объект абстрактного типа `MapDataSource`, который может быть одним из трех конкретных типов: `CircleSource`, `GeojsonSource` и `PolylineSource`.

```kotlin
class CircleSource(
 val id: String, // уникальный id источника данных
 val center: LatLon, // центр круга
 val radius: Double, // радиус в метрах
 val steps: Int // количество ребер в интерполяции круга
)

class GeojsonSource(
 val id: String, // уникальный id источника данных
 val geojsonData: ByteArray // GeoJson строка в виде ByteArray
)

class PolylineSource(
 val id: String, // уникальный id источника данных
 val polylineData: String // закодированная в строку информация о полилинии
)
```

Для добавления функциональности геокодирования и/или изохронов необходимо прописать зависимость.

### Пример добавления зависимостей

```gradle
implementation('ru.mail.maps:vk-maps-api:x.x.x')
```

Далее необходимо создать сущность интерфейса `GeocodeApi` через `Builder`:

```kotlin
val mapsApi = VkMapsApi.Builder().apiKey(API_KEY).build()
```

Чтобы использовать функциональность геокодирования и изохронов, необходимо вызывать методы `geocode` и `iso` соответственно.

- **Геокодирование** Kotlin`val response = mapsApi.geocode("Москва")`
- **Изохроны** Kotlin`val response = mapsApi.iso(locations = listOf(LatLon()), contours = listOf( Contour(time = 15, color = "ff0000", distance = 0f), Contour(time = 30, color = "00ff00", distance = 0f) ) )`

В качестве ответа возвращается объект класса `ResponseWrapper`, который может содержать результат геокодирования `Success` и список результатов типа `Result` в поле `value` или ошибку типа `HttpError` или `GeneralError`.

## Ограничения

Минимально поддерживаемая версия Android: 7.0 (min sdk 24)
