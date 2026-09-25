package moe.rukamori.archivetune.canvas

import moe.rukamori.archivetune.canvas.models.CanvasArtwork

object ArchiveTuneCanvas {
    suspend fun getBySongArtist(
        song: String,
        artist: String,
        storefront: String?,
        source: CanvasSource,
        requireVertical: Boolean,
        forceRefresh: Boolean
    ): CanvasArtwork? = null
    
    suspend fun isHealthy(): Boolean = false
}
