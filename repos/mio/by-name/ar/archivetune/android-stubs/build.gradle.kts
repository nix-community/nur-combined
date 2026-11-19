plugins {
    kotlin("jvm")
    id("org.jetbrains.compose") version "1.13.0-rc01"
    id("org.jetbrains.kotlin.plugin.compose")
}
repositories {
    google()
    mavenCentral()
}
dependencies {
    implementation("com.squareup.okhttp3:okhttp:5.4.0")
    implementation(compose.runtime)
    implementation(compose.ui)
    implementation(compose.foundation)
    implementation(compose.materialIconsExtended)
    // Stubs in package androidx.compose.material3 extend the real Material3 API
    // (ListItemDefaults, MaterialTheme, ColorScheme...), so they need it at compile
    // time. :app brings the real artefact to the runtime classpath.
    // The compose plugin pins material3 at 1.9.0; upstream v16 targets the 1.5 API line,
    // so request the 1.13.0-rc01 artefact explicitly (same release train as the plugin).
    compileOnly("org.jetbrains.compose.material3:material3:1.13.0-rc01")
    // The lyrics-ui stub is typed with lyrics-core's model interfaces (ISyncedLine/SyncedLyrics)
    // so upstream's `{ line -> line.start }` lambdas infer a real receiver; :app brings the
    // artefact to the runtime classpath.
    compileOnly("com.mocharealm.accompanist:lyrics-core:0.4.7")
    // media3's BitmapLoader and the kotlinx-coroutines guava adapter are typed in
    // terms of ListenableFuture, so the real Guava is needed to compile them.
    implementation("com.google.guava:guava:33.6.0-jre")
    api("org.jetbrains.kotlinx:kotlinx-serialization-json:1.11.0")
}
