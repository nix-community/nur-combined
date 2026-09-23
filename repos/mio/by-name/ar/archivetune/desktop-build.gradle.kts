import org.jetbrains.compose.desktop.application.dsl.TargetFormat

plugins {
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.compose.multiplatform)
    alias(libs.plugins.compose.compiler)
}

kotlin {
    jvmToolchain(21)
}

dependencies {
    implementation(project(":core"))

    // Compose Desktop
    implementation(compose.desktop.currentOs)
    implementation(compose.material3)
    implementation(compose.components.resources)
}

compose.desktop {
    application {
        mainClass = "moe.rukamori.archivetune.desktop.MainKt"

        buildTypes.release.proguard {
            isEnabled.set(false)
        }

        nativeDistributions {
            targetFormats(TargetFormat.Deb, TargetFormat.AppImage)
            packageName = "ArchiveTune"
            packageVersion = "15.0.0"
            description = "The Cutest Music Player with YouTube Music support"
            vendor = "rukamori"

            linux {
                // We'll just rely on the wrapper for the icon on Linux
                appCategory = "AudioVideo"
            }
        }
    }
}
