package moe.rukamori.archivetune.kugou

/*
 * The :lyrics:kugou submodule is not fetched by fetchFromGitHub, so the port declares the
 * surface KuGouLyricsProvider resolves against. Upstream calls
 * `KuGou.getLyrics(title, artist, duration)` positionally. No lyrics are ever produced.
 */
object KuGou {
    var useTraditionalChinese = false

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
        callback: (String) -> Unit = {},
        album: String? = null,
    ): Result<String>? = null

    suspend fun getAllPossibleLyricsOptions(
        title: String,
        artist: String,
        duration: Int = 0,
        callback: (String) -> Unit = {},
    ) {}
}
