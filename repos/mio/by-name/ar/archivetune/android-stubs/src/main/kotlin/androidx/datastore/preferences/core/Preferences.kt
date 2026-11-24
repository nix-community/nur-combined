package androidx.datastore.preferences.core

abstract class Preferences {
    abstract operator fun <T> get(key: Key<T>): T?
    open fun <T> contains(key: Key<T>): Boolean = false
    abstract fun asMap(): Map<Key<*>, Any>
    open fun toMutablePreferences(): MutablePreferences = MutablePreferences()
    open class Key<T>(val name: String = "") {
        override fun equals(other: Any?): Boolean = other is Key<*> && other.name == name

        override fun hashCode(): Int = name.hashCode()

        override fun toString(): String = "Preferences.Key(name=$name)"
    }
    companion object { }
}
