package androidx.media3.common

open class Timeline {
    open class Window {
        val firstPeriodIndex: Int = 0
        val lastPeriodIndex: Int = 0
        val uid: Any = Any()
        val isLive: Boolean = false
        val isDynamic: Boolean = false
        val isSeekable: Boolean = true
        val durationMs: Long = 0L
        val defaultPositionMs: Long = 0L
        val currentPositionMs: Long = 0L
        val mediaItem: MediaItem = MediaItem.Builder().build()
    }
    
    open class Period {
        val windowIndex: Int = 0
    }
    
    open fun getWindow(windowIndex: Int, window: Window): Window = window
    open fun getPeriod(periodIndex: Int, period: Period): Period = period
    open val windowCount: Int = 0
    open val periodCount: Int = 0

    open val isEmpty: Boolean
        get() = windowCount == 0

    open fun getFirstWindowIndex(shuffleModeEnabled: Boolean): Int = 0
    open fun getLastWindowIndex(shuffleModeEnabled: Boolean): Int = 0
    open fun getNextWindowIndex(
        windowIndex: Int,
        repeatMode: Int,
        shuffleModeEnabled: Boolean,
    ): Int = windowIndex
    open fun getPreviousWindowIndex(
        windowIndex: Int,
        repeatMode: Int,
        shuffleModeEnabled: Boolean,
    ): Int = windowIndex
}
