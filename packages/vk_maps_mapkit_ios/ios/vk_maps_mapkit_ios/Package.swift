// swift-tools-version: 5.10

import PackageDescription

// Версия нативного SDK задаётся здесь и в podspec. Значения обязаны
// совпадать — это проверяется тестом tool/check_sdk_versions.dart.
let package = Package(
    name: "vk_maps_mapkit_ios",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "vk-maps-mapkit-ios",
            targets: ["vk_maps_mapkit_ios"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/maps-mailru/vk-maps-distribution.git",
            exact: "1.4.4.14633"
        )
    ],
    targets: [
        .target(
            name: "vk_maps_mapkit_ios",
            dependencies: [
                .product(name: "MapsNativeSDK", package: "vk-maps-distribution")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
