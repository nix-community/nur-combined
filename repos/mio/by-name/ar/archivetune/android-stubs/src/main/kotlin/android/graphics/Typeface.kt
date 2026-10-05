package android.graphics
class Typeface {
    companion object {
        fun create(familyName: String, style: Int): Typeface = Typeface()
        fun defaultFromStyle(style: Int): Typeface = Typeface()
        val DEFAULT: Typeface = Typeface()
        val DEFAULT_BOLD: Typeface = Typeface()
        val SANS_SERIF: Typeface = Typeface()
        val SERIF: Typeface = Typeface()
        val MONOSPACE: Typeface = Typeface()
        val NORMAL = 0
        val BOLD = 1
        val ITALIC = 2
        val BOLD_ITALIC = 3
    }
}
