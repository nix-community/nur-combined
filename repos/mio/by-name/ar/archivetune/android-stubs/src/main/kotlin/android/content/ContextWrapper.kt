package android.content

open class ContextWrapper(context: Context?) : Context() {
    open val baseContext: Context = context ?: DummyContext()
    override val filesDir: java.io.File get() = baseContext.filesDir
    override val cacheDir: java.io.File get() = baseContext.cacheDir
    override val packageName: String get() = baseContext.packageName
    override val contentResolver: ContentResolver get() = baseContext.contentResolver
    override val applicationContext: Context get() = baseContext.applicationContext
    override fun getDatabasePath(name: String): java.io.File = baseContext.getDatabasePath(name)
    override fun openFileOutput(name: String, mode: Int): java.io.FileOutputStream = baseContext.openFileOutput(name, mode)
}
