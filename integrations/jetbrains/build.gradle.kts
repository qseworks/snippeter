import org.jetbrains.intellij.platform.gradle.IntelliJPlatformType

plugins {
    id("java")
    id("org.jetbrains.kotlin.jvm") version "1.9.25"
    id("org.jetbrains.intellij.platform") version "2.1.0"
}

group = "io.snippeter"
version = "1.0.0"

repositories {
    mavenCentral()
    intellijPlatform {
        defaultRepositories()
    }
}

dependencies {
    // JSON parsing — no supabase SDK on the JVM, plain HttpClient + org.json.
    implementation("org.json:json:20240303")

    intellijPlatform {
        // Target IntelliJ IDEA Community 2024.2 (build 242).
        intellijIdeaCommunity("2024.2")
        instrumentationTools()
    }
}

intellijPlatform {
    pluginConfiguration {
        id = "io.snippeter.jetbrains"
        name = "Snippeter"
        version = project.version.toString()
        vendor {
            name = "Snippeter"
        }
        ideaVersion {
            sinceBuild = "242"
            untilBuild = "242.*"
        }
    }
}

kotlin {
    jvmToolchain(17)
}

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

tasks {
    withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
        kotlinOptions {
            jvmTarget = "17"
        }
    }
}
