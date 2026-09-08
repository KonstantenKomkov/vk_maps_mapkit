#!/usr/bin/env bash
# Проверяет, что версия нативного SDK одинакова везде, где она указана.
#
# Версия iOS SDK живёт в двух файлах — Package.swift и podspec, — и при
# обновлении их легко развести. Тогда приложение на SPM и приложение на
# CocoaPods получат разные SDK, а разница вылезет уже у пользователя.
set -euo pipefail
cd "$(dirname "$0")/.."

PACKAGE_SWIFT=packages/vk_maps_mapkit_ios/ios/vk_maps_mapkit_ios/Package.swift
PODSPEC=packages/vk_maps_mapkit_ios/ios/vk_maps_mapkit_ios.podspec

spm_version=$(grep -oE 'exact: "[0-9.]+"' "$PACKAGE_SWIFT" | grep -oE '[0-9.]+' | head -1)
pod_version=$(grep -E "s.dependency 'VKMapsSDK'" "$PODSPEC" | grep -oE "'[0-9]+(\.[0-9]+)+'" | tr -d "'" | head -1)

if [ -z "$spm_version" ] || [ -z "$pod_version" ]; then
  echo "Не удалось прочитать версию SDK: SPM='$spm_version', CocoaPods='$pod_version'"
  exit 1
fi

if [ "$spm_version" != "$pod_version" ]; then
  echo "Версии iOS SDK разошлись: Package.swift — $spm_version, podspec — $pod_version"
  exit 1
fi

echo "Версия iOS SDK одинакова в обоих режимах подключения: $spm_version"
