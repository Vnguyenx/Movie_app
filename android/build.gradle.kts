// 1. Khai báo các Plugin ở đầu file
plugins {
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
    // Đây là dòng quan trọng nhất để sửa lỗi của bạn
    id("com.google.gms.google-services") version "4.4.2" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 2. Cấu hình thư mục build (Đã sửa lại cho gọn và đúng chuẩn Kotlin DSL)
rootProject.layout.buildDirectory.set(rootProject.layout.projectDirectory.dir("../../build"))

subprojects {
    project.layout.buildDirectory.set(rootProject.layout.buildDirectory.get().dir(project.name))
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}