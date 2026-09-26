package androidx.media3.common

interface Player {
    var playWhenReady: Boolean
    val playbackState: Int
    var repeatMode: Int
    val currentTimeline: Timeline
    val currentMediaItemIndex: Int
    var shuffleModeEnabled: Boolean
    val mediaItemCount: Int
    val isPlaying: Boolean
    val isLoading: Boolean
    val duration: Long
    val currentPosition: Long
    val bufferedPosition: Long
    val totalBufferedDuration: Long
    val currentMediaItem: MediaItem?

    fun prepare()
    fun play()
    fun pause()
    fun stop()
    fun release()
    fun seekToDefaultPosition()
    fun seekToDefaultPosition(mediaItemIndex: Int)
    fun seekTo(positionMs: Long)
    fun seekTo(mediaItemIndex: Int, positionMs: Long)
    fun seekToPrevious()
    fun seekToNext()
    fun seekToPreviousMediaItem()
    fun seekToNextMediaItem()
    fun setMediaItem(mediaItem: MediaItem)
    fun setMediaItems(mediaItems: List<MediaItem>)
    fun setMediaItems(mediaItems: List<MediaItem>, startIndex: Int, startPositionMs: Long)
    fun addMediaItem(mediaItem: MediaItem)
    fun addMediaItem(index: Int, mediaItem: MediaItem)
    fun addMediaItems(mediaItems: List<MediaItem>)
    fun addMediaItems(index: Int, mediaItems: List<MediaItem>)
    fun removeMediaItem(index: Int)
    fun removeMediaItems(fromIndex: Int, toIndex: Int)
    fun clearMediaItems()
    fun moveMediaItem(currentIndex: Int, newIndex: Int)
    fun moveMediaItems(fromIndex: Int, toIndex: Int, newIndex: Int)
    fun replaceMediaItem(index: Int, mediaItem: MediaItem)
    fun replaceMediaItems(fromIndex: Int, toIndex: Int, mediaItems: List<MediaItem>)
    fun getMediaItemAt(index: Int): MediaItem
    fun hasNextMediaItem(): Boolean
    fun hasPreviousMediaItem(): Boolean
    fun setPlaybackSpeed(speed: Float)
    fun setVolume(volume: Float)
    fun addListener(listener: Listener)
    fun removeListener(listener: Listener)

    interface Listener {
        fun onPlaybackStateChanged(playbackState: Int) {}
        fun onPlayWhenReadyChanged(playWhenReady: Boolean, reason: Int) {}
        fun onIsPlayingChanged(isPlaying: Boolean) {}
        fun onMediaItemTransition(mediaItem: MediaItem?, reason: Int) {}
        fun onPositionDiscontinuity(oldPosition: PositionInfo, newPosition: PositionInfo, reason: Int) {}
        fun onShuffleModeEnabledChanged(shuffleModeEnabled: Boolean) {}
        fun onRepeatModeChanged(repeatMode: Int) {}
        fun onTimelineChanged(timeline: Timeline, reason: Int) {}
        fun onTracksChanged(tracks: Any) {}
        fun onPlayerError(error: Any) {}
        fun onPlaybackParametersChanged(playbackParameters: Any) {}
        fun onMediaMetadataChanged(mediaMetadata: MediaMetadata) {}
        fun onIsLoadingChanged(isLoading: Boolean) {}
        fun onVolumeChanged(volume: Float) {}
    }

    data class PositionInfo(val mediaItemIndex: Int = 0, val positionMs: Long = 0L, val mediaItem: MediaItem? = null)

    companion object {
        const val STATE_IDLE = 1
        const val STATE_BUFFERING = 2
        const val STATE_READY = 3
        const val STATE_ENDED = 4

        const val REPEAT_MODE_OFF = 0
        const val REPEAT_MODE_ONE = 1
        const val REPEAT_MODE_ALL = 2

        const val DISCONTINUITY_REASON_AUTO_TRANSITION = 0
        const val DISCONTINUITY_REASON_SEEK = 1
        const val DISCONTINUITY_REASON_SEEK_ADJUSTMENT = 2
        const val DISCONTINUITY_REASON_SKIP = 3
        const val DISCONTINUITY_REASON_REMOVE = 4
        const val DISCONTINUITY_REASON_INTERNAL = 5

        const val MEDIA_ITEM_TRANSITION_REASON_REPEAT = 0
        const val MEDIA_ITEM_TRANSITION_REASON_AUTO = 1
        const val MEDIA_ITEM_TRANSITION_REASON_SEEK = 2
        const val MEDIA_ITEM_TRANSITION_REASON_PLAYLIST_CHANGED = 3

        const val TIMELINE_CHANGE_REASON_PLAYLIST_CHANGED = 0
        const val TIMELINE_CHANGE_REASON_SOURCE_UPDATE = 1

        const val PLAY_WHEN_READY_CHANGE_REASON_USER_REQUEST = 1
    }
}
