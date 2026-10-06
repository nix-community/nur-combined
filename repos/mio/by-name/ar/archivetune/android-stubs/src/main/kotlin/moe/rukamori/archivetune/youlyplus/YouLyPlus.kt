package moe.rukamori.archivetune.youlyplus

/*
 * The :lyrics:youlyplus submodule is not fetched by fetchFromGitHub, so the port declares the
 * surface YouLyPlusLyricsProvider resolves against. No lyrics are ever produced.
 */
object YouLyPlus {
    var logger: (String) -> Unit = {}

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
