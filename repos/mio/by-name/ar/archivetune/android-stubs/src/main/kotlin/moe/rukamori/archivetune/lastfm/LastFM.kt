package moe.rukamori.archivetune.lastfm

object LastFM {
    const val DEFAULT_SCROBBLE_MIN_SONG_DURATION = 30
    const val DEFAULT_SCROBBLE_DELAY_PERCENT = 50f
    const val DEFAULT_SCROBBLE_DELAY_SECONDS = 240
    const val DEFAULT_API_ENDPOINT = ""
    const val LIBREFM_API_ENDPOINT = ""
    const val FALLBACK_COMPAT_API_KEY = ""
    const val FALLBACK_COMPAT_SECRET = ""
    
    var sessionKey: String? = null
    
    class LastFmException(val code: Int, message: String) : Exception(message)

    fun initialize(apiKey: String, secret: String) {}
    fun configure(apiEndpoint: String, apiKey: String, secret: String) {}
    fun normalizeEndpoint(endpoint: String): String = endpoint
    
    suspend fun authenticate(username: String, password: String): Result<moe.rukamori.archivetune.lastfm.models.Authentication> = Result.success(
        moe.rukamori.archivetune.lastfm.models.Authentication(
            moe.rukamori.archivetune.lastfm.models.Authentication.Session("", "", 0)
        )
    )
    
    suspend fun updateNowPlaying(
        artist: String,
        track: String,
        album: String? = null,
        trackNumber: Int? = null,
        duration: Int? = null,
    ): Result<String> = Result.success("")
    
    suspend fun scrobble(
        artist: String,
        track: String,
        timestamp: Long,
        album: String? = null,
        trackNumber: Int? = null,
        duration: Int? = null,
    ): Result<String> = Result.success("")
}
