package moe.rukamori.archivetune.spotify.models

open class SpotifyInternalToken(
    val accessToken: String = "",
    val clientId: String = "",
    val accessTokenExpirationTimestampMs: Long = 0L,
    val isAnonymous: Boolean = false
)
