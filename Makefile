.PHONY: bootstrap check format analyze test gen example-android example-ios clean

bootstrap:  ## Поставить зависимости во всех пакетах
	@./tool/bootstrap.sh

check:      ## Формат, анализ и тесты по всем пакетам
	@./tool/check.sh

format:     ## Отформатировать код
	@dart format packages

analyze:    ## Только анализ
	@for p in packages/*/; do echo "==> $$p"; (cd $$p && flutter analyze --fatal-infos || dart analyze --fatal-infos); done

test:       ## Только тесты
	@for p in packages/*/; do \
		if [ -d "$$p/test" ]; then echo "==> $$p"; (cd $$p && (flutter test || dart test)); fi; \
	done

gen:        ## Перегенерировать Pigeon-контракт
	@cd packages/vk_maps_mapkit_platform_interface && dart run pigeon --input pigeons/messages.dart

example-android: ## Запустить example на Android
	@cd packages/vk_maps_mapkit/example && flutter run -d android --dart-define=VK_MAPS_API_KEY=$${VK_MAPS_API_KEY}

example-ios:     ## Запустить example на iOS
	@cd packages/vk_maps_mapkit/example && flutter run -d ios --dart-define=VK_MAPS_API_KEY=$${VK_MAPS_API_KEY}

clean:      ## Убрать артефакты сборки
	@find packages -name .dart_tool -type d -prune -exec rm -rf {} + ; \
	 find packages -name build -type d -prune -exec rm -rf {} +
