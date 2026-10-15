package androidx.media3.common

open class Timeline {
    companion object {
        @JvmField
        val EMPTY: Timeline = object : Timeline() {}
    }
    open class Window {
        var firstPeriodIndex: Int = 0
        var lastPeriodIndex: Int = 0
        var uid: Any = Any()
        var isLive: Boolean = false
        var isDynamic: Boolean = false
        var isSeekable: Boolean = true
        var durationMs: Long = 0L
        var defaultPositionMs: Long = 0L
        var currentPositionMs: Long = 0L
        var mediaItem: MediaItem = MediaItem.Builder().build()
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
