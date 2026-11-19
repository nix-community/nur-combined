package android.text

import android.graphics.Paint

open class Layout {
    enum class Alignment { ALIGN_NORMAL, ALIGN_CENTER, ALIGN_OPPOSITE }

    open val height: Int = 0
    open val width: Int = 0

    open fun getLineCount(): Int = 0
    open fun getLineHeight(line: Int): Int = 0
    open fun draw(canvas: android.graphics.Canvas) {}
}

open class StaticLayout : Layout() {
    class Builder private constructor() {
        fun setAlignment(alignment: Alignment): Builder = this
        fun setIncludePad(includePad: Boolean): Builder = this
        fun setMaxLines(maxLines: Int): Builder = this
        fun setEllipsize(ellipsize: TextUtils.TruncateAt?): Builder = this
        fun setLineSpacing(spacingAdd: Float, spacingMult: Float): Builder = this
        fun build(): StaticLayout = StaticLayout()

        companion object {
            @JvmStatic
            fun obtain(
                text: CharSequence,
                start: Int,
                end: Int,
                paint: TextPaint,
                width: Int
            ): Builder = Builder()
        }
    }
}

open class TextPaint : Paint {
    constructor() : super()
    constructor(flags: Int) : super(flags)
    constructor(paint: Paint) : super()

    var bgColor: Int = 0
    var baselineShift: Int = 0
    var linkColor: Int = 0
}

object TextUtils {
    enum class TruncateAt { START, MIDDLE, END, MARQUEE }

    @JvmStatic
    fun isEmpty(text: CharSequence?): Boolean = text.isNullOrEmpty()

    @JvmStatic
    fun join(delimiter: CharSequence, tokens: Iterable<*>): String = tokens.joinToString(delimiter)
}
