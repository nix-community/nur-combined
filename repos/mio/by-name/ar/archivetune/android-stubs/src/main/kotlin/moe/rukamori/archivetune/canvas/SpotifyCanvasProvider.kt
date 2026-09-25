package moe.rukamori.archivetune.canvas

import moe.rukamori.archivetune.canvas.models.CanvasArtwork

open class SpotifyCanvasProvider(val accessToken: String? = null, val clientId: String? = null) {
    class RequestException(val statusCode: Int = 0) : Exception()
    suspend fun getBySongArtist(song: String, artist: String): CanvasArtwork? = null
    suspend fun isHealthy(): Boolean = false
}
