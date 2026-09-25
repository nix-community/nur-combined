plugins {
    kotlin("jvm")
    id("org.jetbrains.compose") version "1.7.0"
    id("org.jetbrains.kotlin.plugin.compose")
}

compose.desktop {
    application {
        mainClass = "moe.rukamori.archivetune.DesktopMainKt"
        nativeDistributions {
            packageName = "ArchiveTune"
        }
        buildTypes.release.proguard {
            isEnabled.set(false)
        }
    }
}

dependencies {
    implementation(compose.desktop.currentOs)
    implementation(compose.material3)
    implementation(project(":core"))
    implementation(project(":android-stubs"))
    implementation("org.robolectric:android-all:14-robolectric-10818077")
}
