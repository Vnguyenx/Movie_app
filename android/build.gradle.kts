// 1. Khai báo các Plugin ở đầu file
plugins {
    // Sửa 8.1.0 thành 8.7.0 theo đúng thông báo lỗi
    id("com.android.application") version "8.7.0" apply false
    
    // Nâng cấp bản Kotlin lên để tương thích với Gradle mới (thường là 1.9.22 hoặc 2.0.0)
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
    
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
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