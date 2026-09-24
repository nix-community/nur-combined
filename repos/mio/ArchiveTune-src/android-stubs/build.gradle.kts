
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
    implementation(compose.runtime)
    compileOnly("org.robolectric:android-all:14-robolectric-10818077")
}
