// android/app/build.gradle.kts

import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Try to load keystore properties if key.properties exists
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.pixelmind.varahiowner"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.pixelmind.varahiowner"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Use your existing key.jks from production_key folder
            val keystorePath = "../../production_key/key.jks"
            val keystoreFile = file(keystorePath)
            
            if (keystoreFile.exists()) {
                storeFile = keystoreFile
                
                // Try to get passwords from properties file first
                if (keystorePropertiesFile.exists()) {
                    storePassword = keystoreProperties.getProperty("storePassword") ?: ""
                    keyAlias = keystoreProperties.getProperty("keyAlias") ?: ""
                    keyPassword = keystoreProperties.getProperty("keyPassword") ?: ""
                } else {
                    // IMPORTANT: Replace these with your actual keystore passwords
                    storePassword = "123456789"  // Change this
                    keyAlias = "key0"            // Change this
                    keyPassword = "123456789"      // Change this
                }
            } else {
                println("Keystore not found at: ${keystoreFile.absolutePath}")
                // If you want to create a debug keystore temporarily
           
            }
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}