package moe.rukamori.archivetune.unison

/*
 * The :lyrics:unison submodule is not fetched by fetchFromGitHub, so the port declares the
 * surface UnisonLyricsProvider resolves against. Upstream calls it with
 * (videoId = ..., title, artist, album, duration). No lyrics are ever produced.
 */
object Unison {
    var logger: (String) -> Unit = {}

    suspend fun getLyrics(
        videoId: String,
        title: String = "",
        artist: String = "",
        album: String? = null,
        duration: Int = 0,
        durationSeconds: Int = 0,
        id: String? = null,
    ): Result<String> = Result.failure(NotImplementedError())

    suspend fun getAllLyrics(
        videoId: String,
        title: String = "",
        artist: String = "",
        album: String? = null,
        duration: Int = 0,
        durationSeconds: Int = 0,
        id: String? = null,
        callback: (String) -> Unit = {},
    ) {}
}
