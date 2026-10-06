package moe.rukamori.archivetune

// Mirrors the buildConfigFields the upstream Android build script generates.
// Values are inert defaults: the desktop port does not sign in to Last.fm, does
// not talk to the ArchiveTune data server and never self-updates.
object BuildConfig {
    const val GITHUB_OWNER = "RukaMori"
    const val GITHUB_REPO = "ArchiveTune"
    const val RELEASE_GITHUB_OWNER = "RukaMori"
    const val RELEASE_GITHUB_REPO = "ArchiveTune"
    const val DISTRIBUTION = "github"
    const val DEVICE = "desktop"
    const val UPDATER_AVAILABLE = true
    const val VERSION_NAME = "15.1.0"
    const val VERSION_CODE = 1
    const val DEBUG = false
    const val ARCHITECTURE = "desktop"
    const val IS_NIGHTLY_BUILD = false
    const val DISCORD_APPLICATION_ID = "1165706613961789445"
    const val DISCORD_APPLICATION_ID_LONG = 1165706613961789445L
    const val DISCORD_REDIRECT_SCHEME = "discord-1165706613961789445"
    const val LASTFM_API_KEY = ""
    const val LASTFM_SECRET = ""
    const val TOGETHER_BEARER_TOKEN = ""
    const val DATA_SERVER_URL = "archive-tune-admin-remote.vercel.app"
    const val API_BEARER_TOKEN = ""
    const val GATEKEEPER_ENABLED = false
    const val LEAK_CANARY_TOGGLE_AVAILABLE = false
    const val NIGHTLY_BUILD_HASH = ""
}
