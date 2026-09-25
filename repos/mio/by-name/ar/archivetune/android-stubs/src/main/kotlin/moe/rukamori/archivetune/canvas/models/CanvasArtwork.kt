package moe.rukamori.archivetune.canvas.models

data class CanvasArtwork(
    val static: String? = null,
    val source: moe.rukamori.archivetune.canvas.CanvasSource = moe.rukamori.archivetune.canvas.CanvasSource.ALL
) {
    fun matches(request: Any): Boolean = true
}

fun matchesSongIdentity(any: Any) {}
