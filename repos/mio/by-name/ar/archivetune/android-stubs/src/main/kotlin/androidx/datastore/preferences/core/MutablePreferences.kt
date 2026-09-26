package androidx.datastore.preferences.core

open class MutablePreferences : Preferences() {
    override operator fun <T> get(key: Preferences.Key<T>): T? = null
    override fun <T> contains(key: Preferences.Key<T>): Boolean = false
    override fun asMap(): Map<Preferences.Key<*>, Any> = emptyMap()
    operator fun <T> set(key: Preferences.Key<T>, value: T) {}
    fun <T> remove(key: Preferences.Key<T>): T? = null
    fun clear() {}
}

fun Preferences.toMutablePreferences(): MutablePreferences = MutablePreferences()
