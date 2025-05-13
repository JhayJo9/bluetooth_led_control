buildscript {
    val kotlinVersion by extra("1.9.24") // Updated to match your system's Kotlin version

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.0.0") // Updated for Gradle 8.x compatibility
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = File("../build")
subprojects {
    project.buildDir = File("${rootProject.buildDir}/${project.name}")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}