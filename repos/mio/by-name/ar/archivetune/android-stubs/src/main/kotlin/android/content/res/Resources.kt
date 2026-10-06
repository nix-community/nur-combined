package android.content.res

open class Resources {
    open fun getIdentifier(name: String, defType: String, defPackage: String): Int = 0
    open fun getStringArray(id: Int): Array<String> = emptyArray()
    open fun getQuantityString(id: Int, quantity: Int): String = ""
    open fun getQuantityString(id: Int, quantity: Int, vararg formatArgs: Any): String = ""
    open fun openRawResource(id: Int): java.io.InputStream = java.io.ByteArrayInputStream(ByteArray(0))
    open fun getInteger(id: Int): Int = 0
    open fun getDimensionPixelSize(id: Int): Int = 0
    open class Theme {
        open fun obtainStyledAttributes(attrs: IntArray): Any = Any()
    }
    open val configuration: Configuration = Configuration()
    open val displayMetrics: android.util.DisplayMetrics = android.util.DisplayMetrics()
    open fun updateConfiguration(config: Configuration, metrics: android.util.DisplayMetrics) {}
}
