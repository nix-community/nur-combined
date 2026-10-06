package androidx.media3.common

open class VideoSize(
    val width: Int = 0,
    val height: Int = 0,
    val unappliedRotationDegrees: Int = 0,
    val pixelWidthHeightRatio: Float = 1f,
) {
    companion object {
        val UNKNOWN = VideoSize()
    }
}
