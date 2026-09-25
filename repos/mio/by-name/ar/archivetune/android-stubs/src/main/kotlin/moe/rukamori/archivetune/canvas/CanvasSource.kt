package moe.rukamori.archivetune.canvas

enum class CanvasSource {
    TIDAL,
    SPOTIFY,
    BETTER_LYRICS,
    APPLE_MUSIC,
    ALL;

    fun accepts(other: CanvasSource): Boolean = true
}
