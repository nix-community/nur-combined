// Replaces the upstream settings script wholesale: the port only builds :core
// (the shared innertube/backend submodule) plus :app and :android-stubs. The
// other upstream submodules (lyrics, lastfm, canvas, shazamkit, spotifycore,
// IconPack, morideobfuscator) are not fetched by fetchFromGitHub and are stubbed.
pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven("https://jitpack.io")
    }
}

include(":core")
include(":app")
include(":android-stubs")

// These are plain directories inside the ArchiveTune source (not git submodules) and
// their build scripts use kotlin.jvm, so they compile as-is: the port builds them for
// real instead of hand-stubbing their APIs. Only :core, :lyrics, :IconPack and
// :morideobfuscator are submodules, and fetchFromGitHub does not fetch those.
include(":spotifycore")
include(":canvas")
include(":lastfm")
include(":shazamkit")
