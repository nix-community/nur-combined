package androidx.core.view

import android.view.View

/* androidx.core's ViewCompat; upstream reads the root window insets through it. */
object ViewCompat {
    @JvmStatic
    fun getRootWindowInsets(view: View?): WindowInsetsCompat = WindowInsetsCompat()

    @JvmStatic
    fun setOnApplyWindowInsetsListener(view: View?, listener: Any?) {}

    @JvmStatic
    fun requestApplyInsets(view: View?) {}

    @JvmStatic
    fun setAccessibilityDelegate(view: View?, delegate: Any?) {}

    @JvmStatic
    fun isAttachedToWindow(view: View?): Boolean = true
}
