package androidx.media3.common

interface Player {
    var playWhenReady: Boolean
    val playbackState: Int
    var repeatMode: Int
    val currentTimeline: Timeline
    val currentMediaItemIndex: Int
    var shuffleModeEnabled: Boolean

    fun prepare()
    fun seekToDefaultPosition()
    
    companion object {
        const val STATE_IDLE = 1
        const val STATE_BUFFERING = 2
        const val STATE_READY = 3
        const val STATE_ENDED = 4
        
        const val REPEAT_MODE_OFF = 0
        const val REPEAT_MODE_ONE = 1
        const val REPEAT_MODE_ALL = 2
    }
}
