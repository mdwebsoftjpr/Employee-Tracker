plugins {
    id("com.android.application")
    id("kotlin-android")
    // Must be last
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.employee_tracker"

    // ✅ Set compile SDK to a fixed value or via flutter object
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // ✅ Good for native image plugins, etc.

    defaultConfig {
        applicationId = "com.example.employee_tracker"
        minSdk = flutter.minSdkVersion
        targetSdk = 30 // ✅ Explicitly set targetSdk to 30 for legacy storage support
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // ✅ Good if your app has many methods/plugins
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            // ✅ Customize signing if needed
            signingConfig = signingConfigs.getByName("debug")
            isShrinkResources = false
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    // ✅ Optional: if you have Jetifier or legacy dependencies
    packagingOptions {
        resources {
            excludes += setOf("META-INF/DEPENDENCIES", "META-INF/LICENSE", "META-INF/LICENSE.txt", "META-INF/NOTICE", "META-INF/NOTICE.txt")
        }
    }
}

flutter {
    source = "../.."
}
