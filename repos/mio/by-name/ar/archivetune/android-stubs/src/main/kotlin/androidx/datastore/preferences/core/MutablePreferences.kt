package androidx.datastore.preferences.core

open class MutablePreferences : Preferences() {
    operator fun <T> set(key: Key<T>, value: T) {}
    fun clear() {}
    override operator fun <T> get(key: Key<T>): T? = null    fun <T> remove(key: Key<T>) {}
    override fun asMap(): Map<Preferences.Key<*>, Any> = emptyMap()
}
