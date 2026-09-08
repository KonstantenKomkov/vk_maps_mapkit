#!/usr/bin/env bash
# Проверяет доступность артефактов нативных SDK.
#
# Результат заносится в docs/platform-matrix.md с датой: состояние выкладки
# меняется, и вывод «недоступно» полугодовой давности ничего не значит.
set -uo pipefail

check() {
  local name=$1 url=$2
  local code
  code=$(curl -sL -o /dev/null -m 20 -w '%{http_code}' "$url" || echo 000)
  printf '%-52s %s  %s\n' "$name" "$code" "$url"
}

echo "== iOS =="
check "SPM: репозиторий дистрибутива" "https://github.com/maps-mailru/vk-maps-distribution"
check "SPM: подспек релиза 1.4.4.14633" \
  "https://raw.githubusercontent.com/maps-mailru/vk-maps-distribution/1.4.4.14633/VKMapsSDK.podspec"
printf '%-52s ' "CocoaPods trunk: версии VKMapsSDK"
curl -s -m 20 "https://trunk.cocoapods.org/api/v1/pods/VKMapsSDK" |
  python3 -c "import sys,json; d=json.load(sys.stdin); print(', '.join(v['name'] for v in d.get('versions',[])[-3:]))" 2>/dev/null ||
  echo "не удалось получить"

echo
echo "== Android =="
check "Maven из документации" \
  "https://artifactory-external.vkpartner.ru/artifactory/maps-sdk-android/"
check "Maven: путь к mapkit из документации" \
  "https://artifactory-external.vkpartner.ru/artifactory/maps-sdk-android/ru/mail/maps/mapkit/"
printf '%-52s ' "Nexus: репозитории с картами"
curl -s -m 20 "https://nexus-external.vkteam.ru/service/rest/v1/repositories" |
  python3 -c "
import sys,json
d=json.load(sys.stdin)
maps=[r['name'] for r in d if 'map' in r['name'].lower()]
print(', '.join(maps) if maps else 'ни одного')" 2>/dev/null || echo "не удалось получить"
printf '%-52s ' "Maven Central: com.vk.maps"
curl -s -m 20 -H 'Accept: application/json' \
  "https://search.maven.org/solrsearch/select?q=g:%22com.vk.maps%22&rows=5&wt=json" |
  python3 -c "
import sys,json
try:
    print(json.load(sys.stdin)['response']['numFound'], 'артефактов')
except Exception:
    print('ответ не разобран')" 2>/dev/null || echo "не удалось получить"
