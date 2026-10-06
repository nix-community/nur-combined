package moe.rukamori.archivetune.simpmusic

/*
 * The :lyrics:simpmusic submodule is not fetched by fetchFromGitHub, so the port declares the
 * surface SimpMusicLyricsProvider resolves against. No lyrics are ever produced.
 */
object SimpMusicLyrics {
    var logger: (String) -> Unit = {}

    suspend fun getLyrics(
        videoId: String,
        duration: Int = 0,
        title: String = "",
        artist: String = "",
    ): Result<String> = Result.failure(NotImplementedError())

    suspend fun getAllLyrics(
        videoId: String,
        duration: Int = 0,
        title: String = "",
        artist: String = "",
        callback: (String) -> Unit = {},
    ): Result<String>? = null
}
