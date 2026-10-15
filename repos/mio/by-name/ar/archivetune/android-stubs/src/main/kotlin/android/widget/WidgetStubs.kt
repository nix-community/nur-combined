package android.widget

import android.content.Context
import android.text.method.MovementMethod
import android.view.ViewGroup

open class FrameLayout(context: Context) : ViewGroup(context) {
    open class LayoutParams(width: Int = 0, height: Int = 0) : ViewGroup.LayoutParams(width, height)
}

open class TextView(context: Context) : ViewGroup(context) {
    var text: CharSequence = ""
    var movementMethod: MovementMethod? = null
    var typeface: android.graphics.Typeface? = null

    open fun setTextColor(color: Int) {}
    open fun setTextSize(size: Float) {}
    open fun setTextSize(unit: Int, size: Float) {}
}

open class Toast(val context: Context) {
    var duration: Int = 0

    open fun show() {}

    companion object {
        const val LENGTH_SHORT = 0
        const val LENGTH_LONG = 1

        @JvmStatic
        fun makeText(context: Context, text: CharSequence, duration: Int): Toast = Toast(context)

        @JvmStatic
        fun makeText(context: Context, resId: Int, duration: Int): Toast = Toast(context)
    }
}
