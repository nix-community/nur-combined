package androidx.datastore.preferences.core

open class MutablePreferences(
    internal val values: java.util.concurrent.ConcurrentHashMap<String, Any> = java.util.concurrent.ConcurrentHashMap()
) : Preferences() {

    @Suppress("UNCHECKED_CAST")
    override operator fun <T> get(key: Preferences.Key<T>): T? {
        val raw = values[key.name] ?: return null
        return when {
            raw is Boolean -> raw as T
            raw is Int -> raw as T
            raw is Long -> raw as T
            raw is Float -> raw as T
            raw is Double -> raw as T
            raw is String -> {
                val str = raw.toString()
                when (str) {
                    "true" -> (true as? T) ?: (str as T)
                    "false" -> (false as? T) ?: (str as T)
                    else -> {
                        (str.toIntOrNull() as? T)
                            ?: (str.toLongOrNull() as? T)
                            ?: (str.toFloatOrNull() as? T)
                            ?: (str.toDoubleOrNull() as? T)
                            ?: (str as T)
                    }
                }
            }
            raw is Set<*> -> raw as T
            else -> raw as? T
        }
    }

    override fun <T> contains(key: Preferences.Key<T>): Boolean = values.containsKey(key.name)

    override fun asMap(): Map<Preferences.Key<*>, Any> =
        values.mapKeys { (k, _) -> Preferences.Key<Any>(k) }

    operator fun <T> set(key: Preferences.Key<T>, value: T) {
        if (value == null) {
            values.remove(key.name)
        } else {
            values[key.name] = value
        }
    }

    @Suppress("UNCHECKED_CAST")
    fun <T> remove(key: Preferences.Key<T>): T? = values.remove(key.name) as? T

    fun clear() {
        values.clear()
    }

    override fun toMutablePreferences(): MutablePreferences =
        MutablePreferences(java.util.concurrent.ConcurrentHashMap(values))
}

fun Preferences.toMutablePreferences(): MutablePreferences =
    (this as? MutablePreferences)?.toMutablePreferences() ?: MutablePreferences()
