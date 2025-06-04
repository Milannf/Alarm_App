// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.alarmapp" // Ganti ini dengan namespace aplikasi Anda yang benar
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Versi NDK yang Anda miliki

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // Ini penting untuk desugaring
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.alarmapp" // Pastikan ini sesuai dengan ID aplikasi Anda
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Pastikan ini ada
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    // Tambahkan dependensi lain yang mungkin sudah ada di proyek Anda di sini jika ada
}