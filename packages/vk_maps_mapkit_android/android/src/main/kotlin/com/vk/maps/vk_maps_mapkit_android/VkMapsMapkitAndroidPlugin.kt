package com.vk.maps.vk_maps_mapkit_android

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import ru.mail.maps.sdk.MapGlobalConfig
import ru.mail.maps.sdk.MapViewConfig

/** Точка входа плагина на Android. */
class VkMapsMapkitAndroidPlugin : FlutterPlugin {

  private val registry = VkMapViewRegistry()

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    binding.platformViewRegistry.registerViewFactory(
      VIEW_TYPE,
      VkMapViewFactory(registry, binding.binaryMessenger),
    )
    VkMapsInitializerApi.setUp(binding.binaryMessenger, VkMapsInitializerApiImpl())
    VkMapsHostApi.setUp(binding.binaryMessenger, VkMapsHostApiImpl(registry))
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    VkMapsInitializerApi.setUp(binding.binaryMessenger, null)
    VkMapsHostApi.setUp(binding.binaryMessenger, null)
    registry.clear()
  }

  private companion object {
    const val VIEW_TYPE = "vk_maps_mapkit/map"
  }
}

/** Реестр созданных карт: мост обращается к ним по идентификатору. */
internal class VkMapViewRegistry {
  private val views = mutableMapOf<Long, VkMapPlatformView>()

  fun register(view: VkMapPlatformView, id: Long) {
    views[id] = view
  }

  fun require(id: Long): VkMapPlatformView =
    views[id]
      ?: throw FlutterError("unknown_view", "Карты с идентификатором $id нет", null)

  fun remove(id: Long) {
    views.remove(id)?.dispose()
  }

  fun clear() {
    views.values.forEach { it.dispose() }
    views.clear()
  }
}

/** Фабрика нативных представлений карты. */
internal class VkMapViewFactory(
  private val registry: VkMapViewRegistry,
  private val binaryMessenger: BinaryMessenger,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    // Параметры карты приходят отдельным вызовом initializeView сразу после
    // создания представления, поэтому аргументы здесь не нужны.
    val view = VkMapPlatformView(context, viewId.toLong(), binaryMessenger)
    registry.register(view, viewId.toLong())
    return view
  }
}

/** Разовая настройка SDK. */
internal class VkMapsInitializerApiImpl : VkMapsInitializerApi {
  private var configured = false

  override fun setup(
    apiKey: String,
    baseUrl: String?,
    locale: String?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    // Повторный вызов не переинициализирует SDK.
    if (configured) {
      callback(Result.success(true))
      return
    }
    callback(
      runCatching {
        MapGlobalConfig.setMapGlobalConfig(MapViewConfig(apiKey = apiKey))
        configured = true
        true
      }
    )
  }

  override fun isInitialized(): Boolean = configured
}
