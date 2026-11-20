// Replaces the upstream Android application build script wholesale.
// The port builds :app as a Compose Desktop (JVM) application; everything that
// used to come from the Android Gradle plugin is provided by :android-stubs.
plugins {
    kotlin("jvm")
    kotlin("plugin.serialization")
    id("org.jetbrains.compose") version "1.13.0-rc01"
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

// Some upstream modules request the compose plugin's default material3 (1.9.0); without a
// force the JVM variant of that older line can win over the explicit expressive artefact,
// which hides the expressive APIs (MediumFlexibleTopAppBar, motionScheme, ...).
configurations.all {
    resolutionStrategy {
        force("org.jetbrains.compose.material3:material3:1.13.0-rc01")
        force("org.jetbrains.compose.material3:material3-desktop:1.13.0-rc01")
    }
}

compose.desktop {
    application {
        mainClass = "moe.rukamori.archivetune.DesktopMainKt"
        nativeDistributions {
            packageName = "ArchiveTune"
            macOS {
                iconFile.set(project.file("ArchiveTune.icns"))
            }
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
        resources.srcDir("src/main/res")
    }
}

dependencies {
    implementation(compose.desktop.currentOs)
    // The compose plugin pins material3 at 1.9.0; upstream v16 targets the Material3 1.5 API
    // line (expressive components), so request the 1.13.0-rc01 artefact explicitly.
    implementation("org.jetbrains.compose.material3:material3:1.13.0-rc01")
    implementation(compose.materialIconsExtended)
    implementation(project(":core"))
    implementation(project(":android-stubs"))
    // Real modules shipped in the ArchiveTune tree (plain directories, kotlin.jvm).
    implementation(project(":spotifycore"))
    implementation(project(":modules"))
    implementation(project(":canvas"))
    implementation(project(":lastfm"))
    implementation(project(":shazamkit"))
    // Lyrics providers and TTML parsers from the :lyrics submodule (kotlin.jvm).
    implementation(project(":lyrics:kugou"))
    implementation(project(":lyrics:lrclib"))
    implementation(project(":lyrics:simpmusic"))
    implementation(project(":lyrics:paxsenix"))
    implementation(project(":lyrics:betterlyrics"))
    implementation(project(":lyrics:unison"))
    implementation(project(":lyrics:youlyplus"))
    implementation(project(":lyrics:lrcred"))
    implementation(project(":lyrics:binimum"))
    implementation(project(":lyrics:megalobiz"))
    implementation(project(":lyrics:musixmatch"))

    // Real Compose-lifecycle integration. The port used to ship hand-written stubs in
    // :android-stubs, but those shadowed the real classes at runtime (their lifecycle
    // state was always RESUMED, which made Compose 1.13's saved-state attach throw
    // "Restarter must be created only during owner's initialization stage").
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.11.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel:2.11.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.11.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-savedstate:2.11.0")

    implementation("androidx.room:room-runtime:2.8.4")
    ksp("androidx.room:room-compiler:2.8.4")
    implementation("androidx.sqlite:sqlite-bundled:2.5.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-swing:1.11.0")

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
    // Brings org.commonmark, which WhatsNewUseCase parses release notes with.
    implementation("io.noties.markwon:core:4.6.2")
    // Glass/blur backgrounds (compose multiplatform builds).
    implementation("dev.chrisbanes.haze:haze:2.1.0")
    implementation("dev.chrisbanes.haze:haze-blur:2.1.0")
    implementation("dev.chrisbanes.haze:haze-glass:2.1.0")

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
