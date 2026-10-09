package android.content.res

open class Configuration {
    constructor()
    constructor(config: Configuration)
    
    @JvmField var screenWidthDp: Int = 0
    @JvmField var screenHeightDp: Int = 0
    @JvmField var densityDpi: Int = 0
    @JvmField var fontScale: Float = 1f
    @JvmField var orientation: Int = ORIENTATION_PORTRAIT
    @JvmField var smallestScreenWidthDp: Int = 0
    @JvmField var locales: android.os.LocaleList = android.os.LocaleList.getDefault()
    
    open fun setLocale(locale: java.util.Locale) {}
    
    companion object {
        const val ORIENTATION_PORTRAIT = 1
        const val ORIENTATION_LANDSCAPE = 2
        const val ORIENTATION_UNDEFINED = 0
    }
}
