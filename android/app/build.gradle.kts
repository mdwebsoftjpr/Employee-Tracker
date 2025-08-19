plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // Firebase plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.employee_tracker"

    // Use Flutter-defined compile SDK version
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.employee_tracker"
        minSdk = 23
        targetSdk = 35 // Updated for Google Play requirements
        versionName = "0.1.3"
        versionCode = 8
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            // Replace with your real signing config for Play Store
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
            excludes.addAll(
                listOf(
                    "META-INF/DEPENDENCIES",
                    "META-INF/LICENSE",
                    "META-INF/LICENSE.txt",
                    "META-INF/NOTICE",
                    "META-INF/NOTICE.txt"
                )
            )
        }
    }

    lint {
        checkReleaseBuilds = true
        // baseline = file("lint-baseline.xml") // Uncomment if you have a baseline file
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM for consistent versions
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:2.1.10")
    // Firebase Analytics (version managed by BoM)
    implementation("com.google.firebase:firebase-analytics")

    // Add other Firebase dependencies here if needed
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
}
