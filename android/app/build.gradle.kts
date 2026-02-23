plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Thêm dòng này để Firebase hoạt động (nếu bạn dùng Firebase)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.movieapp"
    compileSdk = flutter.compileSdkVersion
    
    // Đã sửa: Ép sử dụng NDK bản 27 như lỗi yêu cầu
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.moiveapp"
        
        // Đã sửa: Nâng minSdk lên 23 để tương thích với Firebase Auth mới
        minSdk = 23 
        
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
            
            // Tối ưu hóa build
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}