package moe.rukamori.archivetune.betterlyrics

/*
 * The :lyrics:betterlyrics submodule is not fetched by fetchFromGitHub, so the port declares the
 * surface BetterLyricsProvider resolves against. No lyrics are ever produced.
 */
object BetterLyrics {
    var logger: (String) -> Unit = {}

    /* Portato is a second provider inside the betterlyrics submodule. */
    suspend fun getPortatoLyrics(
        title: String,
        artist: String,
        album: String? = null,
        durationSeconds: Int = 0,
    ): Result<String> = Result.failure(NotImplementedError())

    suspend fun getAllPortatoLyrics(
        title: String,
        artist: String,
        album: String? = null,
        durationSeconds: Int = 0,
        callback: (String) -> Unit = {},
    ) {}

    suspend fun getLyrics(
        title: String,
        artist: String,
        album: String? = null,
        durationSeconds: Int = 0,
        id: String? = null,
    ): Result<String> = Result.failure(NotImplementedError())

    suspend fun getAllLyrics(
        title: String,
        artist: String,
        album: String? = null,
        durationSeconds: Int = 0,
        id: String? = null,
        callback: (String) -> Unit = {},
    ) {}
}
