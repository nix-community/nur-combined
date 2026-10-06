package moe.rukamori.archivetune.paxsenix

import moe.rukamori.archivetune.paxsenix.models.PaxsenixStats

/*
 * The :lyrics:paxsenix submodule is not fetched by fetchFromGitHub. Upstream's provider set
 * calls PaxsenixLyrics.getSpotifyLyrics / getMusixmatchLyrics / getAppleMusicLyrics with
 * (title, artist, duration) positionally. No lyrics are ever produced.
 */
object PaxsenixLyrics {
    var logger: (String) -> Unit = {}

    suspend fun getStats(): Result<PaxsenixStats> = Result.success(PaxsenixStats())

    fun setUserAgent(appName: String, version: String) {}

    fun setApiKey(apiKey: String) {}

    suspend fun getLyrics(
        title: String,
        artist: String,
        duration: Int = 0,
        album: String? = null,
    ): Result<String> = Result.failure(NotImplementedError())

    suspend fun getAllLyrics(
        title: String,
        artist: String,
        duration: Int = 0,
        callback: (String) -> Unit = {},
        album: String? = null,
    ): Result<String>? = null

    suspend fun getSpotifyLyrics(
        title: String,
        artist: String,
        duration: Int = 0,
        album: String? = null,
    ): Result<String> = Result.failure(NotImplementedError())

    suspend fun getMusixmatchLyrics(
        title: String,
        artist: String,
        duration: Int = 0,
        album: String? = null,
    ): Result<String> = Result.failure(NotImplementedError())

    suspend fun getAppleMusicLyrics(
        title: String,
        artist: String,
        duration: Int = 0,
        album: String? = null,
    ): Result<String> = Result.failure(NotImplementedError())

    suspend fun getSpotifyAllLyrics(
        title: String,
        artist: String,
        duration: Int = 0,
        callback: (String) -> Unit = {},
    ) {}

    suspend fun getMusixmatchAllLyrics(
        title: String,
        artist: String,
        duration: Int = 0,
        callback: (String) -> Unit = {},
    ) {}

    suspend fun getAppleMusicAllLyrics(
        title: String,
        artist: String,
        duration: Int = 0,
        callback: (String) -> Unit = {},
    ) {}
}
