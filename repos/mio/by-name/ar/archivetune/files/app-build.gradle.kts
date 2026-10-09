// Replaces the upstream Android application build script wholesale.
// The port builds :app as a Compose Desktop (JVM) application; everything that
// used to come from the Android Gradle plugin is provided by :android-stubs.
plugins {
    kotlin("jvm")
    kotlin("plugin.serialization")
    id("org.jetbrains.compose") version "1.7.0"
    id("org.jetbrains.kotlin.plugin.compose")
    id("com.google.devtools.ksp") version "2.3.10"
}

kotlin {
    compilerOptions {
        // Upstream compiles against a newer material3/compose line where these APIs are stable,
        // so its call sites carry no opt-in. The port's compose 1.7 still marks them
        // experimental, which made every such call an error; opt in globally instead of
        // rewriting hundreds of call sites.
        freeCompilerArgs.addAll(
            "-opt-in=androidx.compose.material3.ExperimentalMaterial3Api",
            "-opt-in=androidx.compose.material3.ExperimentalMaterial3ExpressiveApi",
            "-opt-in=androidx.compose.foundation.ExperimentalFoundationApi",
            "-opt-in=androidx.compose.foundation.layout.ExperimentalLayoutApi",
            "-opt-in=androidx.compose.ui.ExperimentalComposeUiApi",
            "-opt-in=androidx.compose.animation.ExperimentalAnimationApi",
            "-opt-in=coil3.annotation.ExperimentalCoilApi",
        )
    }
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

/*
 * Upstream builds Android product flavours; several composables the app calls
 * (GoogleDriveBackupSection, SupportArchiveTuneSection, supportArchiveTuneAvailable) live in
 * app/src/foss/kotlin rather than app/src/main/kotlin. The port builds one flat JVM source set,
 * so the FOSS flavour (the non-Play-Services one) has to be added explicitly.
 */
sourceSets {
    main {
        kotlin.srcDir("src/foss/kotlin")
        // The FOSS flavour also carries a cast/ implementation, which narrow.py drops as an
        // Android-only subsystem; without this the dropped cast types get compiled again.
        kotlin.exclude("**/cast/**")
    }
}

dependencies {
    implementation(compose.desktop.currentOs)
    implementation(compose.material3)
    implementation(project(":core"))
    implementation(project(":android-stubs"))
    // Real modules shipped in the ArchiveTune tree (plain directories, kotlin.jvm).
    implementation(project(":spotifycore"))
    implementation(project(":canvas"))
    implementation(project(":lastfm"))
    implementation(project(":shazamkit"))
    implementation("org.robolectric:android-all:14-robolectric-10818077")

    implementation("androidx.room:room-runtime:2.8.4")
    ksp("androidx.room:room-compiler:2.8.4")
    implementation("androidx.sqlite:sqlite-bundled:2.5.0")

    // Plain-JVM libraries the app uses directly. These used to be hand-stubbed in
    // android-stubs; using the real artifacts instead removes a whole class of
    // "missing member" curation work. Versions match upstream's version catalog.
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.11.0")
    implementation("com.squareup.okhttp3:okhttp:5.4.0")
    implementation("com.squareup.okio:okio:3.17.0")
    implementation("com.google.guava:guava:33.6.0-jre")
    // Upstream's karaoke/synced-lyrics model library (real artifact; only its
    // lyrics-ui companion is published sources-only, so that one is stubbed).
    implementation("com.mocharealm.accompanist:lyrics-core:0.4.7")
    implementation("com.atilika.kuromoji:kuromoji-ipadic:0.9.0")
    // Compose Multiplatform drag-to-reorder (real artifact, JVM-published).
    implementation("sh.calvin.reorderable:reorderable:3.1.0")

    val ktor = "3.5.1"
    implementation("io.ktor:ktor-client-core:$ktor")
    implementation("io.ktor:ktor-client-okhttp:$ktor")
    implementation("io.ktor:ktor-client-content-negotiation:$ktor")
    implementation("io.ktor:ktor-client-websockets:$ktor")
    implementation("io.ktor:ktor-server-core:$ktor")
    implementation("io.ktor:ktor-server-cio:$ktor")
    implementation("io.ktor:ktor-server-websockets:$ktor")
    implementation("io.ktor:ktor-server-content-negotiation:$ktor")
    implementation("io.ktor:ktor-serialization-kotlinx-json:$ktor")
}
