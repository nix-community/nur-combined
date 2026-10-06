package moe.rukamori.archivetune.lrclib

/*
 * The :lyrics:lrclib submodule is not fetched by fetchFromGitHub, so the port declares the
 * surface LrcLibLyricsProvider resolves against. Upstream calls
 * `LrcLib.getAllLyrics(title, artist, duration, album, callback)` positionally.
 * No lyrics are ever produced.
 */
object LrcLib {
    var logger: (String) -> Unit = {}

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
        album: String? = null,
        callback: ((String) -> Unit)? = null,
    ): Result<String>? = null
}
