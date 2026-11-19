// Replaces the upstream settings script wholesale: the port builds :app,
// :android-stubs, the :core innertube/backend submodule and the JVM-only
// :lyrics provider modules. IconPack and morideobfuscator are not fetched and
// are stubbed.
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
// :morideobfuscator are submodules; IconPack and morideobfuscator are stubbed.
include(":spotifycore")
include(":modules")
include(":canvas")
include(":lastfm")
include(":shazamkit")

// The lyrics submodule is fetched by the package and builds as plain Kotlin/JVM.
include(":lyrics:kugou")
include(":lyrics:lrclib")
include(":lyrics:simpmusic")
include(":lyrics:paxsenix")
include(":lyrics:betterlyrics")
include(":lyrics:unison")
include(":lyrics:youlyplus")
include(":lyrics:lrcred")
include(":lyrics:binimum")
include(":lyrics:megalobiz")
include(":lyrics:musixmatch")
