package androidx.datastore.preferences.core


abstract class Preferences {
    abstract operator fun <T> get(key: Key<T>): T?
    abstract fun asMap(): Map<Key<*>, Any>
    open class Key<T>(val name: String = "")
    companion object { }
}

