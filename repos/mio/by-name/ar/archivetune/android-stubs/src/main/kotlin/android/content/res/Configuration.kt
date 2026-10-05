package android.content.res

open class Configuration {
    constructor()
    constructor(config: Configuration)
    var screenWidthDp: Int = 0
    var screenHeightDp: Int = 0
    var densityDpi: Int = 0
    var fontScale: Float = 1f
    var orientation: Int = ORIENTATION_PORTRAIT
    var smallestScreenWidthDp: Int = 0
    open fun setLocale(locale: java.util.Locale) {}
    
    companion object {
        const val ORIENTATION_PORTRAIT = 1
        const val ORIENTATION_LANDSCAPE = 2
        const val ORIENTATION_UNDEFINED = 0
    }
}

    
