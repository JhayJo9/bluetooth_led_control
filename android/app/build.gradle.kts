import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { stream ->
        localProperties.load(stream)
    }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

// Updated by Jhayyy14 on 2025-05-13 01:50:14
android {
    namespace = "com.example.bluetooth_led_control"

    // Force SDK version - remove any references to flutter.compileSdkVersion
    compileSdk = 34

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.bluetooth_led_control"
        minSdk = 21

        // Force target SDK - don't use flutter.targetSdkVersion
        targetSdk = 34

        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Add this to force proper resource compilation
    lintOptions {
        disable("InvalidPackage")
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Updated Kotlin stdlib to match your Kotlin version
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:${rootProject.extra["kotlinVersion"]}")
}