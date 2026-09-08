#
# Подключение через CocoaPods. Раскладка каталогов общая с SPM:
# исходники лежат в vk_maps_mapkit_ios/Sources, подспек ссылается внутрь.
#
Pod::Spec.new do |s|
  s.name             = 'vk_maps_mapkit_ios'
  s.version          = '0.1.0'
  s.summary          = 'iOS-реализация плагина vk_maps_mapkit'
  s.description      = <<-DESC
Карта VK Карт во Flutter: нативная часть для iOS поверх VKMapsSDK.
                       DESC
  s.homepage         = 'https://github.com/KonstantenKomkov/vk_maps_mapkit'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Konstantin Komkov' => 'https://github.com/KonstantenKomkov' }
  s.source           = { :path => '.' }
  s.source_files     = 'vk_maps_mapkit_ios/Sources/vk_maps_mapkit_ios/**/*.swift'
  s.dependency 'Flutter'
  # Версия обязана совпадать с Package.swift.
  s.dependency 'VKMapsSDK', '1.4.4.14633'
  s.platform         = :ios, '15.0'
  s.swift_version    = '5.10'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    # Имена фреймворков в CocoaPods и SPM различаются; флаг позволяет
    # развести редкие случаи прямо в коде.
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) VK_MAPS_USING_COCOAPODS=1'
  }
  s.resource_bundles = {
    'vk_maps_mapkit_ios_privacy' => ['vk_maps_mapkit_ios/Sources/vk_maps_mapkit_ios/Resources/PrivacyInfo.xcprivacy']
  }
end
