package android.content

open class Intent {
    constructor()
    constructor(action: String)
    constructor(action: String, uri: android.net.Uri)
    constructor(context: Context, cls: Class<*>)
    constructor(intent: Intent)

    var clipData: android.content.ClipData? = null
    val data: android.net.Uri? = null
    val extras: android.os.Bundle? = null
    var action: String? = null
    var type: String? = null
    var flags: Int = 0

    fun getStringExtra(name: String): String? = null
    fun getIntExtra(name: String, defaultValue: Int): Int = defaultValue
    fun getBooleanExtra(name: String, defaultValue: Boolean): Boolean = defaultValue
    fun getLongExtra(name: String, defaultValue: Long): Long = defaultValue
    fun getParcelableExtra(name: String): Any? = null
    fun putExtra(name: String, value: String?): Intent = this
    fun putExtra(name: String, value: Int): Intent = this
    fun putExtra(name: String, value: Boolean): Intent = this
    fun putExtra(name: String, value: Long): Intent = this
    fun putExtra(name: String, value: android.os.Bundle?): Intent = this
    fun putExtra(name: String, value: Any?): Intent = this
    fun setAction(action: String): Intent = this
    fun addFlags(flags: Int): Intent = this
    fun setData(uri: android.net.Uri): Intent = this
    fun setPackage(pkg: String): Intent = this
    fun setClass(context: Context, cls: Class<*>): Intent = this
    fun setType(type: String): Intent = this
    fun setClassName(packageName: String, className: String): Intent = this
    fun setClassName(context: Context, className: String): Intent = this
    fun addCategory(category: String): Intent = this
    fun setDataAndType(data: android.net.Uri, type: String): Intent = this
    val dataString: String? get() = data?.toString()
    fun resolveActivity(packageManager: android.content.pm.PackageManager?): android.content.ComponentName? = null

    companion object {
        fun createChooser(target: Intent, title: CharSequence?): Intent = Intent()

        fun parseUri(uriString: String, flags: Int): Intent? = null

        const val URI_INTENT_SCHEME = 1
        const val EXTRA_TEXT = "android.intent.extra.TEXT"
        const val EXTRA_STREAM = "android.intent.extra.STREAM"
        const val ACTION_MAIN = "android.intent.action.MAIN"
        const val ACTION_VIEW = "android.intent.action.VIEW"
        const val ACTION_SEND = "android.intent.action.SEND"
        const val ACTION_PICK = "android.intent.action.PICK"
        const val ACTION_GET_CONTENT = "android.intent.action.GET_CONTENT"
        const val ACTION_WEB_SEARCH = "android.intent.action.WEB_SEARCH"
        const val ACTION_DIAL = "android.intent.action.DIAL"
        const val ACTION_SENDTO = "android.intent.action.SENDTO"
        const val ACTION_SEARCH = "android.intent.action.SEARCH"
        const val EXTRA_QUERY = "android.intent.extra.QUERY"
        const val CATEGORY_LAUNCHER = "android.intent.category.LAUNCHER"
        const val CATEGORY_BROWSABLE = "android.intent.category.BROWSABLE"
        const val FLAG_ACTIVITY_CLEAR_TASK = 32768
        const val FLAG_ACTIVITY_NEW_TASK = 0x10000000
        const val FLAG_ACTIVITY_SINGLE_TOP = 0x20000000
        const val FLAG_ACTIVITY_CLEAR_TOP = 0x04000000
        const val FLAG_GRANT_READ_URI_PERMISSION = 0x00000001
        const val FLAG_GRANT_WRITE_URI_PERMISSION = 0x00000002
    }
}
