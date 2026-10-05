package moe.rukamori.archivetune.spotify

import moe.rukamori.archivetune.spotify.models.*

object Spotify {
    var accessToken: String? = null
    fun playlist(id: String): Result<SpotifyPlaylist> = Result.success(SpotifyPlaylist())
    fun myPlaylists(limit: Int = 0, offset: Int = 0): Result<SpotifyPaging<SpotifyPlaylist>> = Result.success(SpotifyPaging())
    fun internalToken(spDc: String, spKey: String): Result<SpotifyInternalToken> = Result.success(SpotifyInternalToken())
    
    class SpotifyException(val statusCode: Int = 0) : Exception()
}
