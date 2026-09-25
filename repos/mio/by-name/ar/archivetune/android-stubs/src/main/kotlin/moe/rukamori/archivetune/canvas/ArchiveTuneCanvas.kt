package moe.rukamori.archivetune.canvas

import moe.rukamori.archivetune.canvas.models.CanvasArtwork

object ArchiveTuneCanvas {
    suspend fun getBySongArtist(song: String, artist: String, provider: CanvasSource): CanvasArtwork? = null
}
