plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")  // UPDATED FROM kotlin-android
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Google Services Plugin
}

android {
    namespace = "com.example.matracking"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Set the NDK version here

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.matracking"
        minSdk = 23  // Updated from flutter.minSdkVersion to 23
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
    // Import the Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:33.11.0"))

    // Add Firebase dependencies
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-database")
    implementation("com.google.firebase:firebase-auth")

    // Fix for flutter_local_notifications desugaring issue
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
