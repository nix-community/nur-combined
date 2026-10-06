package android.view

/*
 * NOTE: this fake shadows android-all's android.view.ViewTreeObserver (a project
 * dependency wins over android-all on :app's classpath). android-all's WebView and
 * View declare members typed with this class's *nested listener interfaces*, so those
 * interfaces must exist here or android-all classes fail to resolve their own
 * supertypes ("Cannot access ... which is a supertype of ...").
 */
open class ViewTreeObserver {
    interface OnGlobalFocusChangeListener {
        fun onGlobalFocusChanged(oldFocus: View?, newFocus: View?)
    }

    interface OnGlobalLayoutListener {
        fun onGlobalLayout()
    }

    interface OnPreDrawListener {
        fun onPreDraw(): Boolean
    }

    interface OnScrollChangedListener {
        fun onScrollChanged()
    }

    interface OnTouchModeChangeListener {
        fun onTouchModeChanged(isInTouchMode: Boolean)
    }

    interface OnWindowAttachListener {
        fun onWindowAttached()

        fun onWindowDetached()
    }

    fun interface OnWindowFocusChangeListener {
        fun onWindowFocusChanged(hasFocus: Boolean)
    }

    fun addOnGlobalFocusChangeListener(listener: OnGlobalFocusChangeListener) {}

    fun removeOnGlobalFocusChangeListener(listener: OnGlobalFocusChangeListener) {}

    fun addOnGlobalLayoutListener(listener: OnGlobalLayoutListener) {}

    @Deprecated("Deprecated in Java")
    fun removeGlobalOnLayoutListener(listener: OnGlobalLayoutListener) {}

    fun removeOnGlobalLayoutListener(listener: OnGlobalLayoutListener) {}

    fun addOnPreDrawListener(listener: OnPreDrawListener) {}

    fun removeOnPreDrawListener(listener: OnPreDrawListener) {}

    fun addOnScrollChangedListener(listener: OnScrollChangedListener) {}

    fun removeOnScrollChangedListener(listener: OnScrollChangedListener) {}

    fun addOnTouchModeChangeListener(listener: OnTouchModeChangeListener) {}

    fun removeOnTouchModeChangeListener(listener: OnTouchModeChangeListener) {}

    fun addOnWindowAttachListener(listener: OnWindowAttachListener) {}

    fun removeOnWindowAttachListener(listener: OnWindowAttachListener) {}

    fun addOnWindowFocusChangeListener(listener: OnWindowFocusChangeListener) {}

    fun removeOnWindowFocusChangeListener(listener: OnWindowFocusChangeListener) {}

    fun dispatchOnGlobalLayout() {}

    fun dispatchOnPreDraw(): Boolean = true

    val isAlive: Boolean = true
}
