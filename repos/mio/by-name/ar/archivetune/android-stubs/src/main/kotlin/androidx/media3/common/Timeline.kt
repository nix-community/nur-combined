package androidx.media3.common

open class Timeline {
    open class Window {
        val firstPeriodIndex: Int = 0
        val lastPeriodIndex: Int = 0
    }
    
    open fun getWindow(windowIndex: Int, window: Window): Window = window
}
