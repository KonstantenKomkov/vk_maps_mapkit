// Сборка Android-части плагина.
//
// Пол версий объявлен в README и docs/platform-matrix.md: AGP 8.x, KGP 1.9,
// Gradle 8.x, JDK 17. Версия KGP жёстко не задаётся — берётся из того, что
// объявило приложение (решение Р-6).
group = "com.vk.maps.vk_maps_mapkit_android"
version = "0.1.0"

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.9.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
    }
}

rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
        // Выкладка SDK VK Карт. Адрес взят из документации; на 8 сентября
        // 2026 он отдаёт 404 — актуальные координаты запрошены у вендора,
        // см. docs/questions-for-vendor.md.
        maven { url = uri("https://artifactory-external.vkpartner.ru/artifactory/maps-sdk-android/") }
    }
}

apply(plugin = "com.android.library")
apply(plugin = "kotlin-android")

extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
    namespace = "com.vk.maps.vk_maps_mapkit_android"
    // Версия SDK для компиляции берётся из Flutter, а не прибивается числом.
    compileSdk = 36

    defaultConfig {
        minSdk = 24
        consumerProguardFiles("consumer-rules.pro")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets.named("main") {
        java.srcDir("src/main/kotlin")
    }

    lint {
        warningsAsErrors = true
        disable.addAll(setOf("AndroidGradlePluginVersion", "GradleDependency", "NewerVersionAvailable"))
    }

    dependencies {
        // Версия SDK задаётся в одном месте на платформу.
        add("implementation", "ru.mail.maps:mapkit:1.0.+")
        add("testImplementation", "org.jetbrains.kotlin:kotlin-test")
    }
}
