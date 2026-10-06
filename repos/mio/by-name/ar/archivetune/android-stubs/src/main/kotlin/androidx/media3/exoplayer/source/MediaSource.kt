package androidx.media3.exoplayer.source

open class MediaSource {
    /* Identifies one media period within a media source. */
    class MediaPeriodId(
        val periodUid: Any? = null,
        val adGroupIndex: Int = -1,
        val adIndexInAdGroup: Int = -1,
    )

    interface Factory {
        fun createMediaSource(mediaItem: androidx.media3.common.MediaItem): MediaSource
    }

    companion object { }
}
