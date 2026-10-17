package android.content

import android.content.res.Configuration
import android.content.res.Resources
import android.database.DatabaseErrorHandler
import android.database.sqlite.SQLiteDatabase
import androidx.compose.runtime.Stable
import java.io.File

object DesktopStoragePaths {
    private val isMac: Boolean by lazy {
        val os = System.getProperty("os.name", "").lowercase()
        os.contains("mac") || os.contains("darwin")
    }

    private val userHome: String by lazy {
        System.getProperty("user.home", ".")
    }

    val configDir: File by lazy {
        val dir = if (isMac) {
            File(userHome, "Library/Application Support/archivetune")
        } else {
            val xdgConfig = System.getenv("XDG_CONFIG_HOME")?.takeIf { it.isNotBlank() }
                ?: (userHome + File.separator + ".config")
            File(xdgConfig, "archivetune")
        }
        dir.apply { mkdirs() }
    }

    val dataDir: File by lazy {
        val dir = if (isMac) {
            File(userHome, "Library/Application Support/archivetune")
        } else {
            val xdgData = System.getenv("XDG_DATA_HOME")?.takeIf { it.isNotBlank() }
                ?: (userHome + File.separator + ".local" + File.separator + "share")
            File(xdgData, "archivetune")
        }
        dir.apply { mkdirs() }
    }

    val cacheDir: File by lazy {
        val dir = if (isMac) {
            File(userHome, "Library/Caches/archivetune")
        } else {
            val xdgCache = System.getenv("XDG_CACHE_HOME")?.takeIf { it.isNotBlank() }
                ?: (userHome + File.separator + ".cache")
            File(xdgCache, "archivetune")
        }
        dir.apply { mkdirs() }
    }

    val runtimeDir: File by lazy {
        val xdgRuntime = System.getenv("XDG_RUNTIME_DIR")?.takeIf { it.isNotBlank() }
        val dir = if (xdgRuntime != null && File(xdgRuntime).exists() && File(xdgRuntime).isDirectory) {
            File(xdgRuntime)
        } else {
            File(System.getProperty("java.io.tmpdir", "/tmp"))
        }
        dir
    }
}

@Stable
open class Context {
    open val contentResolver: ContentResolver = ContentResolver()
    open val packageName: String = "moe.rukamori.archivetune"
    open val filesDir: File get() = DesktopStoragePaths.dataDir
    open val cacheDir: File get() = DesktopStoragePaths.cacheDir
    open val externalCacheDir: File? get() = DesktopStoragePaths.cacheDir
    open val resources: Resources = Resources()
    open val assets: android.content.res.AssetManager = android.content.res.AssetManager()
    open val mainLooper: Any? = null
    open val packageManager: android.content.pm.PackageManager = android.content.pm.PackageManager()
    open val classLoader: ClassLoader = ClassLoader.getSystemClassLoader()
    open val applicationContext: Context = this

    open fun getDrawable(id: Int): android.graphics.drawable.Drawable? = null
    open fun openRawResource(id: Int): java.io.InputStream =
        java.io.ByteArrayInputStream(ByteArray(0))
    open fun getString(resId: Int): String = androidx.compose.ui.res.StringResources.stringMap[resId] ?: ""
    open fun getString(resId: Int, vararg formatArgs: Any?): String =
        try {
            val str = androidx.compose.ui.res.StringResources.stringMap[resId] ?: ""
            String.format(str, *formatArgs)
        } catch (e: Exception) {
            ""
        }
    open fun getSystemService(name: String): Any? = when (name) {
        AUDIO_SERVICE -> android.media.AudioManager()
        CONNECTIVITY_SERVICE -> android.net.ConnectivityManager()
        ACTIVITY_SERVICE -> android.app.ActivityManager()
        CLIPBOARD_SERVICE -> ClipboardManager()
        POWER_SERVICE -> android.os.PowerManager()
        NOTIFICATION_SERVICE -> android.app.NotificationManager()
        else -> null
    }

    @Suppress("UNCHECKED_CAST")
    open fun <T> getSystemService(serviceClass: Class<T>): T? = when (serviceClass.name) {
        "android.media.AudioManager" -> android.media.AudioManager() as T
        "android.net.ConnectivityManager" -> android.net.ConnectivityManager() as T
        "android.app.ActivityManager" -> android.app.ActivityManager() as T
        "android.content.ClipboardManager" -> ClipboardManager() as T
        "android.os.PowerManager" -> android.os.PowerManager() as T
        "android.app.NotificationManager" -> android.app.NotificationManager() as T
        else -> null
    }
    
    open fun startService(intent: Intent): Any? = null
    open fun stopService(intent: Intent): Boolean = false
    open fun startActivity(intent: Intent) {}
    open fun sendBroadcast(intent: Intent) {}
    open fun registerReceiver(receiver: Any?, filter: Any): Intent? = null
    open fun unregisterReceiver(receiver: Any?) {}
    
    open fun getDatabasePath(name: String): File = File(DesktopStoragePaths.dataDir, name)
    open fun checkSelfPermission(permission: String): Int = 0
    open fun checkPermission(permission: String, pid: Int, uid: Int): Int = 0

    open fun getExternalFilesDirs(type: String?): Array<File?> = arrayOf(getExternalFilesDir(type))

    open fun getExternalFilesDir(type: String?): File? =
        if (type != null) File(DesktopStoragePaths.dataDir, type).apply { mkdirs() } else DesktopStoragePaths.dataDir

    open fun getExternalCacheDirs(): Array<File?> = arrayOf(cacheDir)

    open fun deleteDatabase(name: String): Boolean = getDatabasePath(name).delete()

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
    open fun openFileOutput(name: String, mode: Int): java.io.FileOutputStream =
        java.io.FileOutputStream(File(DesktopStoragePaths.dataDir, name), (mode and MODE_APPEND) != 0)
    open fun openOrCreateDatabase(name: String, mode: Int, factory: SQLiteDatabase.CursorFactory?): SQLiteDatabase = SQLiteDatabase()
    open fun openOrCreateDatabase(name: String, mode: Int, factory: SQLiteDatabase.CursorFactory?, errorHandler: DatabaseErrorHandler?): SQLiteDatabase = SQLiteDatabase()

    companion object {
        const val MODE_PRIVATE = 0
        const val MODE_APPEND = 32768
        const val BIND_AUTO_CREATE = 1
        const val RECEIVER_NOT_EXPORTED = 4
        const val AUDIO_SERVICE = "audio"
        const val CONNECTIVITY_SERVICE = "connectivity"
        const val ACTIVITY_SERVICE = "activity"
        const val CLIPBOARD_SERVICE = "clipboard"
        const val POWER_SERVICE = "power"
        const val NOTIFICATION_SERVICE = "notification"
        const val BATTERY_SERVICE = "batterymanager"
        const val MEDIA_PROJECTION_SERVICE = "media_projection"
        const val SENSOR_SERVICE = "sensor"
    }
}

class DummyContext : Context() {
    override val filesDir: File get() = DesktopStoragePaths.dataDir
    override val cacheDir: File get() = DesktopStoragePaths.cacheDir
    override val packageName: String get() = "moe.rukamori.archivetune"
    override val contentResolver: ContentResolver get() = ContentResolver()
    override val applicationContext: Context get() = this
    override fun getDatabasePath(name: String): File = File(DesktopStoragePaths.dataDir, name)
    override fun openFileOutput(name: String, mode: Int): java.io.FileOutputStream =
        java.io.FileOutputStream(File(DesktopStoragePaths.dataDir, name), (mode and MODE_APPEND) != 0)
}
