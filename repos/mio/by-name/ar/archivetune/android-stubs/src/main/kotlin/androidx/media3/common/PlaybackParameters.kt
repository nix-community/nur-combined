package androidx.media3.common

open class PlaybackParameters(
    val speed: Float = 1f,
    val pitch: Float = 1f,
) {
    companion object {
        val DEFAULT = PlaybackParameters()
    }
}
