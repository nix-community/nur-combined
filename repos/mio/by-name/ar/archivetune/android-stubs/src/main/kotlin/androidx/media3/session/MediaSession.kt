package androidx.media3.session

import androidx.media3.common.MediaItem

open class MediaSession {
    class MediaItemsWithStartPosition(
        val mediaItems: List<MediaItem>,
        val startIndex: Int,
        val startPositionMs: Long
    )
    
    companion object { }
}
