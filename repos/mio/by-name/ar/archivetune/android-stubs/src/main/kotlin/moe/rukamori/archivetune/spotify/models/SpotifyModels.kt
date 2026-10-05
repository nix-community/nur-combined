package moe.rukamori.archivetune.spotify.models

class SpotifyPlaylist(
    val id: String = "",
    val name: String = "",
    val uri: String = "",
    val tracks: SpotifyPlaylistTracksRef? = null
) {
    fun copy(tracks: SpotifyPlaylistTracksRef? = null): SpotifyPlaylist = this
}
class SpotifyPlaylistTracksRef(val total: Int = 0)

class SpotifyArtist(
    val id: String = "",
    val name: String = "",
    val uri: String = ""
)
class SpotifyAlbum(
    val id: String = "",
    val name: String = "",
    val uri: String = "",
    val releaseDate: String = "",
    val totalTracks: Int = 0,
    val images: List<SpotifyImage>? = null
)
class SpotifyImage(
    val url: String = "",
    val width: Int = 0,
    val height: Int = 0
)

class SpotifyTrack(
    val id: String = "",
    val name: String = "",
    val uri: String = "",
    val isLocal: Boolean = false,
    val durationMs: Long = 0,
    val explicit: Boolean = false,
    val album: SpotifyAlbum? = null,
    val artists: List<SpotifyArtist>? = null
)

class SpotifyPaging<T>(val items: List<T> = emptyList())
class SpotifySimpleAlbum
