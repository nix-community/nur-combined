package android.view

import android.content.Context

open class View(val context: Context) {
    constructor() : this(Context())

    interface OnCreateContextMenuListener
    
    open val width: Int = 0
    open val height: Int = 0
    open val isAttachedToWindow: Boolean = true

    open fun getWindowVisibleDisplayFrame(outRect: android.graphics.Rect) {}
    open fun getRootWindowInsets(): Any? = null
    open fun performHapticFeedback(feedbackConstant: Int): Boolean = false
    open fun performHapticFeedback(feedbackConstant: Int, flags: Int): Boolean = false
    open fun keepScreenOn(keepScreenOn: Boolean) {}
    open var keepScreenOn: Boolean = false
    open fun getLocationInWindow(outLocation: IntArray) {}
}
