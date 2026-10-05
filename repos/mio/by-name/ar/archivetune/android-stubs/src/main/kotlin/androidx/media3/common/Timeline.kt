package androidx.media3.common

open class Timeline {
    open class Window {
        val firstPeriodIndex: Int = 0
        val lastPeriodIndex: Int = 0
        val uid: Any? = null
        val mediaItem: MediaItem = MediaItem.Builder().build()
    }
    
    open class Period {
        val windowIndex: Int = 0
    }
    
    open fun getWindow(windowIndex: Int, window: Window): Window = window
    open fun getPeriod(periodIndex: Int, period: Period): Period = period
    open val windowCount: Int = 0
    open val periodCount: Int = 0
}
