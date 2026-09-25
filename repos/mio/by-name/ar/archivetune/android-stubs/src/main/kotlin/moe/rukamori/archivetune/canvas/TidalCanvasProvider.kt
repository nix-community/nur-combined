package moe.rukamori.archivetune.canvas

import moe.rukamori.archivetune.canvas.models.CanvasArtwork

object TidalCanvasProvider {
    suspend fun getBySongArtist(song: String, artist: String, storefront: String?): CanvasArtwork? = null
    suspend fun isHealthy(): Boolean = false
}
