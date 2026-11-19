package moe.rukamori.archivetune.unison

import moe.rukamori.archivetune.unison.models.UnisonLyrics

/*
 * The :lyrics module is built for real, but its Unison client is declared here so the port
 * does not depend on the network surface. No lyrics are ever produced.
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
    ): Result<UnisonLyrics> = Result.failure(NotImplementedError())

    suspend fun getAllLyrics(
        videoId: String,
        title: String = "",
        artist: String = "",
        album: String? = null,
        duration: Int = 0,
        durationSeconds: Int = 0,
        id: String? = null,
        callback: (UnisonLyrics) -> Unit = {},
    ) {}

    fun lyricsPageUrl(lyrics: UnisonLyrics): String = ""

    fun submitterPageUrl(lyrics: UnisonLyrics): String = ""
}
