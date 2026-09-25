package moe.rukamori.archivetune.canvas

open class SpotifyCanvasProvider(val accessToken: String? = null, val clientId: String? = null) {
    class RequestException : Exception()
}

open class SpotifyInternalToken(
    val accessToken: String = "",
    val clientId: String = "",
    val accessTokenExpirationTimestampMs: Long = 0L
)
