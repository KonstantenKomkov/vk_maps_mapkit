# vk_maps_mapkit

Flutter-обёртка над нативными SDK VK Карт для Android и iOS плюс клиент REST-сервисов VK Карт на чистом Dart.

> Неофициальный пакет. Ключ доступа пользователь получает самостоятельно на
> [maps.vk.com](https://maps.vk.com/ru/welcome/); условия использования определяются договором с VK.

**Статус:** в разработке, публичного релиза нет.

## Пакеты

| Пакет | Назначение |
| --- | --- |
| [`vk_maps_mapkit`](packages/vk_maps_mapkit) | фасад: виджет `VkMap`, контроллер, события |
| [`vk_maps_mapkit_platform_interface`](packages/vk_maps_mapkit_platform_interface) | контракт моста и модели |
| [`vk_maps_mapkit_android`](packages/vk_maps_mapkit_android) | реализация для Android |
| [`vk_maps_mapkit_ios`](packages/vk_maps_mapkit_ios) | реализация для iOS |
| [`vk_maps_api`](packages/vk_maps_api) | REST-клиент, не зависит от Flutter |

## Разработка

```bash
make bootstrap   # зависимости во всех пакетах
make check       # формат, анализ, тесты
make gen         # перегенерировать Pigeon-контракт
```

## Документы

- [План разработки](documents/development_plan.md) — этапы, критерии готовности, последовательность.
- [Задачи по документации](documents/documentation_tasks.md) — 37 задач, по одной на страницу документации VK Карт.
- [Принятые решения](docs/design-decisions.md) — что решено и почему, с отвергнутыми вариантами.
- [Правовые вводные](docs/legal-notes.md) — выписки из условий использования с датой проверки.
- [Вопросы вендору](docs/questions-for-vendor.md) — готовое письмо и статус переписки.
- [Матрица поддержки платформ](docs/platform-matrix.md) — что работает на iOS и Android и почему.
- [Сверка с JavaScript SDK](docs/js-sdk-coverage.md) — что из 111 методов эталонного API есть в плагине.
- [Состояние проекта](docs/status.md) — готовность по этапам и что мешает закрыть.
- [Чек-лист живой проверки](docs/live-verification-plan.md) — то, что нельзя закрыть автотестами.
- [Публикация](docs/publishing.md) — порядок и проверки перед релизом.
- [Снимки документации](documents/research/dev_vk_ru/) — 37 страниц `dev.vk.ru` в Markdown.
