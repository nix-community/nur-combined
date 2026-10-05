package moe.rukamori.archivetune.lastfm.models

data class Authentication(
    val session: Session,
) {
    data class Session(
        val name: String, // Username
        val key: String, // Session Key
        val subscriber: Int, // Last.fm Pro?
    )
}

data class TokenResponse(
    val token: String,
)

data class LastFmError(
    val error: Int,
    val message: String,
)
