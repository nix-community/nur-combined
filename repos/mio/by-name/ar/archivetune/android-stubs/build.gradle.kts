plugins {
    kotlin("jvm")
    id("org.jetbrains.compose") version "1.7.0"
    id("org.jetbrains.kotlin.plugin.compose")
}
repositories {
    google()
    mavenCentral()
}
dependencies {
    implementation(libs.okhttp)
    implementation(compose.runtime)
    implementation(compose.ui)
    implementation(compose.foundation)
    compileOnly("org.robolectric:android-all:14-robolectric-10818077")
    api("org.jetbrains.kotlinx:kotlinx-serialization-json:1.11.0")
}
