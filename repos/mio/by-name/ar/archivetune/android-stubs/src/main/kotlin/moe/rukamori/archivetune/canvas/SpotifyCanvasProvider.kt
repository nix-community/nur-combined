package moe.rukamori.archivetune.canvas

import moe.rukamori.archivetune.canvas.models.CanvasArtwork

open class SpotifyCanvasProvider {
    class RequestException(val statusCode: Int = 0) : Exception()

    companion object {
        suspend fun getBySongArtist(song: String, artist: String, accessToken: String?, clientId: String?): CanvasArtwork? = null
        suspend fun isHealthy(accessToken: String?, clientId: String?): Boolean = false
    }
}
