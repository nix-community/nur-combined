package android.content

import android.content.res.Configuration
import android.content.res.Resources
import android.database.DatabaseErrorHandler
import android.database.sqlite.SQLiteDatabase
import androidx.compose.runtime.Stable

@Stable
open class Context {
    open val contentResolver: ContentResolver = ContentResolver()
    open val packageName: String = "moe.rukamori.archivetune"
    open val filesDir: java.io.File = java.io.File("/tmp")
    open val cacheDir: java.io.File = java.io.File("/tmp")
    open val externalCacheDir: java.io.File? = null
    open val resources: Resources = Resources()
    open val assets: android.content.res.AssetManager = android.content.res.AssetManager()
    open val mainLooper: Any? = null
    open val packageManager: android.content.pm.PackageManager = android.content.pm.PackageManager()
    open val classLoader: ClassLoader = ClassLoader.getSystemClassLoader()
    open val applicationContext: Context = this

    open fun getDrawable(id: Int): android.graphics.drawable.Drawable? = null
    open fun openRawResource(id: Int): java.io.InputStream =
        java.io.ByteArrayInputStream(ByteArray(0))
    open fun getString(resId: Int): String = ""
    open fun getString(resId: Int, vararg formatArgs: Any?): String = ""
    open fun getSystemService(name: String): Any? = null
    open fun <T> getSystemService(serviceClass: Class<T>): T? = null
    
    open fun startService(intent: Intent): Any? = null
    open fun stopService(intent: Intent): Boolean = false
    open fun startActivity(intent: Intent) {}
    open fun sendBroadcast(intent: Intent) {}
    open fun registerReceiver(receiver: Any?, filter: Any): Intent? = null
    open fun unregisterReceiver(receiver: Any?) {}
    
    open fun getDatabasePath(name: String): java.io.File = java.io.File("/tmp/$name")
    open fun checkSelfPermission(permission: String): Int = 0
    open fun checkPermission(permission: String, pid: Int, uid: Int): Int = 0

    open fun getExternalFilesDirs(type: String?): Array<java.io.File?> = emptyArray()

    open fun getExternalFilesDir(type: String?): java.io.File? = null

    open fun getExternalCacheDirs(): Array<java.io.File?> = emptyArray()

    open fun deleteDatabase(name: String): Boolean = false

    open fun bindService(intent: Intent, conn: Any, flags: Int): Boolean = false
    open fun unbindService(conn: Any) {}
    open fun getSharedPreferences(name: String, mode: Int): SharedPreferences =
        object : SharedPreferences {
            override fun getString(key: String, defValue: String?): String? = defValue

            override fun getStringSet(key: String, defValues: Set<String>?): Set<String>? = defValues

            override fun getInt(key: String, defValue: Int): Int = defValue

            override fun getLong(key: String, defValue: Long): Long = defValue

            override fun getFloat(key: String, defValue: Float): Float = defValue

            override fun getBoolean(key: String, defValue: Boolean): Boolean = defValue

            override fun contains(key: String): Boolean = false

            override fun edit(): SharedPreferences.Editor = NoopEditor

            override fun getAll(): MutableMap<String, Any?> = mutableMapOf()

            override fun registerOnSharedPreferenceChangeListener(listener: Any) {}

            override fun unregisterOnSharedPreferenceChangeListener(listener: Any) {}
        }
    open fun openFileOutput(name: String, mode: Int): java.io.FileOutputStream = java.io.FileOutputStream("/tmp/$name")
    open fun openOrCreateDatabase(name: String, mode: Int, factory: SQLiteDatabase.CursorFactory?): SQLiteDatabase = SQLiteDatabase()
    open fun openOrCreateDatabase(name: String, mode: Int, factory: SQLiteDatabase.CursorFactory?, errorHandler: DatabaseErrorHandler?): SQLiteDatabase = SQLiteDatabase()

    companion object {
        const val MODE_PRIVATE = 0
        const val MODE_APPEND = 32768
        const val AUDIO_SERVICE = "audio"
        const val CONNECTIVITY_SERVICE = "connectivity"
        const val ACTIVITY_SERVICE = "activity"
        const val CLIPBOARD_SERVICE = "clipboard"
    }
}

class DummyContext : Context()
