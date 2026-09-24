plugins {
    kotlin("jvm")
    id("org.jetbrains.compose") version "1.7.0"
    id("org.jetbrains.kotlin.plugin.compose")
    application
}

application {
    mainClass.set("moe.rukamori.archivetune.DesktopMainKt")
}

dependencies {
    implementation(compose.desktop.currentOs)
    implementation(compose.material3)
    implementation(project(":core"))
}
