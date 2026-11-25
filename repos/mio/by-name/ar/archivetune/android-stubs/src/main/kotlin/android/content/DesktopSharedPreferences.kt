package android.content

import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.Properties
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.CopyOnWriteArrayList

/*
 * Real SharedPreferences backing for the desktop port.
 *
 * The previous stub returned the caller's defaults, discarded every edit and
 * ignored the file name (`getSharedPreferences(name, mode)` built one anonymous
 * store per call). StorageLocationRepository persists its storage-folder choice
 * through it and MoodAndGenresArtworkRepository caches artwork URLs in it, so
 * both silently lost their data; distinct preference files would also have
 * shared one namespace. Values are persisted per name under the config dir.
 */
object DesktopSharedPreferences {
    private val stores = ConcurrentHashMap<String, Store>()

    fun get(name: String): SharedPreferences = stores.getOrPut(name) { Store(name) }
}

internal class Store(private val name: String) : SharedPreferences {
    private val values = ConcurrentHashMap<String, Any>()
    private val listeners = CopyOnWriteArrayList<Any>()

    private val file: File by lazy {
        val safeName = name.replace(Regex("[^A-Za-z0-9._-]"), "_")
        File(DesktopStoragePaths.configDir, "$safeName.properties")
    }

    init {
        load()
    }

    private fun load() {
        try {
            if (!file.exists()) return
            val properties = Properties()
            FileInputStream(file).use { properties.load(it) }
            for (key in properties.stringPropertyNames()) {
                decode(properties.getProperty(key))?.let { values[key] = it }
            }
        } catch (e: Throwable) {
            System.err.println("[SharedPreferences:$name] load failed: ${e.message}")
        }
    }

    private fun persist() {
        try {
            val properties = Properties()
            values.forEach { (key, value) -> properties.setProperty(key, encode(value)) }
            FileOutputStream(file).use { properties.store(it, "ArchiveTune desktop preferences ($name)") }
        } catch (e: Throwable) {
            System.err.println("[SharedPreferences:$name] save failed: ${e.message}")
        }
    }

    private fun encode(value: Any): String =
        when (value) {
            is Boolean -> "b:$value"
            is Int -> "i:$value"
            is Long -> "l:$value"
            is Float -> "f:$value"
            is Set<*> -> "t:" + value.joinToString(",")
            else -> "s:$value"
        }

    private fun decode(encoded: String?): Any? {
        if (encoded == null) return null
        val body = encoded.substringAfter(':', encoded)
        return when {
            encoded.startsWith("b:") -> body.toBooleanStrictOrNull()
            encoded.startsWith("i:") -> body.toIntOrNull()
            encoded.startsWith("l:") -> body.toLongOrNull()
            encoded.startsWith("f:") -> body.toFloatOrNull()
            encoded.startsWith("t:") -> body.split(',').filter(String::isNotEmpty).toSet()
            else -> body
        }
    }

    override fun getString(key: String, defValue: String?): String? = values[key] as? String ?: defValue

    @Suppress("UNCHECKED_CAST")
    override fun getStringSet(key: String, defValues: Set<String>?): Set<String>? =
        values[key] as? Set<String> ?: defValues

    override fun getInt(key: String, defValue: Int): Int = values[key] as? Int ?: defValue

    override fun getLong(key: String, defValue: Long): Long = values[key] as? Long ?: defValue

    override fun getFloat(key: String, defValue: Float): Float = values[key] as? Float ?: defValue

    override fun getBoolean(key: String, defValue: Boolean): Boolean = values[key] as? Boolean ?: defValue

    override fun contains(key: String): Boolean = values.containsKey(key)

    override fun edit(): SharedPreferences.Editor = Editor()

    override fun getAll(): MutableMap<String, Any?> = LinkedHashMap(values)

    override fun registerOnSharedPreferenceChangeListener(listener: Any) {
        listeners.addIfAbsent(listener)
    }

    override fun unregisterOnSharedPreferenceChangeListener(listener: Any) {
        listeners.remove(listener)
    }

    override operator fun get(key: String, defValue: Any?): Any? = values[key] ?: defValue

    override operator fun set(key: String, value: Any?) {
        if (value == null) {
            values.remove(key)
        } else {
            values[key] = value
        }
        persist()
        notifyChanged(key)
    }

    override operator fun set(key: String, value: String?) = set(key, value as Any?)

    override operator fun set(key: String, value: Int) = set(key, value as Any?)

    override operator fun set(key: String, value: Boolean) = set(key, value as Any?)

    override operator fun set(key: String, value: Long) = set(key, value as Any?)

    override fun remove(key: String) {
        values.remove(key)
        persist()
        notifyChanged(key)
    }

    override fun clear() {
        values.clear()
        persist()
        notifyChanged("")
    }

    private fun notifyChanged(key: String) {
        listeners.forEach { listener ->
            try {
                val method =
                    listener.javaClass.methods.firstOrNull {
                        it.name == "onSharedPreferenceChanged" && it.parameterCount == 2
                    }
                method?.isAccessible = true
                method?.invoke(listener, this, key)
            } catch (_: Throwable) {
                // Listeners are optional; a broken one must not fail the write.
            }
        }
    }

    private inner class Editor : SharedPreferences.Editor {
        private val changes = LinkedHashMap<String, Any?>()
        private var clearRequested = false

        override fun putString(key: String, value: String?): SharedPreferences.Editor =
            apply { changes[key] = value }

        override fun putStringSet(key: String, values: Set<String>?): SharedPreferences.Editor =
            apply { changes[key] = values }

        override fun putInt(key: String, value: Int): SharedPreferences.Editor =
            apply { changes[key] = value }

        override fun putLong(key: String, value: Long): SharedPreferences.Editor =
            apply { changes[key] = value }

        override fun putFloat(key: String, value: Float): SharedPreferences.Editor =
            apply { changes[key] = value }

        override fun putBoolean(key: String, value: Boolean): SharedPreferences.Editor =
            apply { changes[key] = value }

        override fun remove(key: String): SharedPreferences.Editor =
            apply { changes[key] = null }

        override fun clear(): SharedPreferences.Editor =
            apply { clearRequested = true }

        override fun commit(): Boolean {
            applyChanges()
            return true
        }

        override fun apply() = applyChanges()

        private fun applyChanges() {
            if (clearRequested) values.clear()
            val changed = LinkedHashSet<String>()
            changes.forEach { (key, value) ->
                if (value == null) {
                    values.remove(key)
                } else {
                    values[key] = value
                }
                changed.add(key)
            }
            changes.clear()
            clearRequested = false
            persist()
            changed.forEach(::notifyChanged)
        }
    }
}
