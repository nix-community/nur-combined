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
    // Stubs in package androidx.compose.material3 extend the real Material3 API
    // (ListItemDefaults, MaterialTheme, ColorScheme...), so they need it at compile
    // time. :app brings the real artefact to the runtime classpath.
    compileOnly(compose.material3)
    // The lyrics-ui stub is typed with lyrics-core's model interfaces (ISyncedLine/SyncedLyrics)
    // so upstream's `{ line -> line.start }` lambdas infer a real receiver; :app brings the
    // artefact to the runtime classpath.
    compileOnly("com.mocharealm.accompanist:lyrics-core:0.4.7")
    // media3's BitmapLoader and the kotlinx-coroutines guava adapter are typed in
    // terms of ListenableFuture, so the real Guava is needed to compile them.
    implementation("com.google.guava:guava:33.6.0-jre")
    compileOnly("org.robolectric:android-all:14-robolectric-10818077")
    api("org.jetbrains.kotlinx:kotlinx-serialization-json:1.11.0")
}
