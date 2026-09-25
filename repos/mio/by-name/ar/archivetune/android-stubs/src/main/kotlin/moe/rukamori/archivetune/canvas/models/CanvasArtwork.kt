package moe.rukamori.archivetune.canvas.models

data class CanvasArtwork(
    val static: String? = null,
    val source: moe.rukamori.archivetune.canvas.CanvasSource = moe.rukamori.archivetune.canvas.CanvasSource.ALL,
    val animated: String? = null,
    val videoUrl: String? = null,
    val animatedVertical: String? = null,
    val videoUrlVertical: String? = null,
    val preferredVerticalAnimationUrl: String? = null,
    val preferredAnimationUrl: String? = null
) {
    fun matches(request: Any): Boolean = true
}

fun matchesSongIdentity(any: Any, any2: Any) {}

fun CanvasArtwork.matchesSongIdentity(title: String, artist: String): Boolean = true
