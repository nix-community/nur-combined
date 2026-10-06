package android.view

import android.content.Context

open class View(val context: Context) {
    constructor() : this(Context())

    interface OnCreateContextMenuListener
    
    open val width: Int = 0
    open val height: Int = 0
    open val rootView: View get() = this
    open val display: Display? = null
    open fun bringToFront() {}
    open fun requestFocus(): Boolean = true
    open fun requestFocus(direction: Int): Boolean = true
    open fun requestFocus(direction: Int, previouslyFocusedRect: Any?): Boolean = true
    open fun requestFocusFromTouch(): Boolean = true
    open fun setRequestedFrameRate(frameRate: Float) {}
    open var isHapticFeedbackEnabled: Boolean = true
    open var isClickable: Boolean = true
    open var isEnabled: Boolean = true
    open fun setOnLongClickListener(listener: Any?) {}
    open val isAttachedToWindow: Boolean = true

    open fun getWindowVisibleDisplayFrame(outRect: android.graphics.Rect) {}
    open fun getRootWindowInsets(): Any? = null
    open fun performHapticFeedback(feedbackConstant: Int): Boolean = false
    open fun performHapticFeedback(feedbackConstant: Int, flags: Int): Boolean = false
    open fun keepScreenOn(keepScreenOn: Boolean) {}
    open var keepScreenOn: Boolean = false
    open fun getLocationInWindow(outLocation: IntArray) {}

    open val viewTreeObserver: ViewTreeObserver
        get() = ViewTreeObserver()

    open fun post(action: Runnable): Boolean = true

    open fun postDelayed(action: Runnable, delayMillis: Long): Boolean = true

    open fun removeCallbacks(action: Runnable) {}

    open fun invalidate() {}

    open fun requestLayout() {}
}
