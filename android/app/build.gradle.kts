plugins {
    id("com.android.application")
    id("kotlin-android")
    // Must be last
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.employee_tracker"

    // ✅ Use Flutter-defined compile SDK version
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.employee_tracker"
        minSdk = flutter.minSdkVersion
        targetSdk = 34 // ✅ Updated to meet Google Play's latest requirements
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
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
            // 🔐 Replace with your real signing config for Play Store
            signingConfig = signingConfigs.getByName("debug")
            isShrinkResources = false
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    packagingOptions {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt"
            )
        }
    }

    lint {
        checkReleaseBuilds = true
        // Optional: baseline = file("lint-baseline.xml")
    }
}

flutter {
    source = "../.."
}
