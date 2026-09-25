package androidx.datastore.preferences.core

abstract class Preferences {
    abstract operator fun <T> get(key: Key<T>): T?
    open fun <T> contains(key: Key<T>): Boolean = false
    abstract fun asMap(): Map<Key<*>, Any>
    open class Key<T>(val name: String = "")
    companion object { }
}
