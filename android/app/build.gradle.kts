import java.util.Properties
import java.io.FileInputStream
import java.io.FileNotFoundException // 추가된 import

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val dotenv = Properties()
val envFile = file("${rootProject.projectDir}/../.env")
// println("Looking for .env file at: ${envFile.path}") // 파일 경로 출력
if (envFile.exists()) {
    
    FileInputStream(envFile).use { dotenv.load(it) }
} else {
    throw FileNotFoundException("Could not find .env file at: ${envFile.path}")
}

android {
    namespace = "com.zypt.focused_study_time_tracker"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.zypt.focused_study_time_tracker"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val kakaoKey = dotenv["KAKAO_NATIVE_APP_KEY"] as String?
        if (kakaoKey == null) {
            throw GradleException("KAKAO_NATIVE_APP_KEY not found in .env file")
        }
        manifestPlaceholders["YOUR_NATIVE_APP_KEY"] = kakaoKey

        // 네이버 로그인 환경변수 설정
        val naverClientId = dotenv["NAVER_CLIENT_ID"] as String?
        val naverClientSecret = dotenv["NAVER_CLIENT_SECRET"] as String?
        val naverAppName = dotenv["NAVER_APP_NAME"] as String?
        
        if (naverClientId == null || naverClientSecret == null || naverAppName == null) {
            throw GradleException("NAVER_CLIENT_ID, NAVER_CLIENT_SECRET, NAVER_APP_NAME not found in .env file")
        }
        
        resValue("string", "client_id", naverClientId)
        resValue("string", "client_secret", naverClientSecret)
        resValue("string", "client_name", naverAppName)
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"), 
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}