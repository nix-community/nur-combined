package androidx.lifecycle

open class SavedStateHandle {
    operator fun <T> get(key: String): T? = null
    operator fun <T> set(key: String, value: T?) {}
    fun <T> getStateFlow(key: String, initialValue: T): kotlinx.coroutines.flow.StateFlow<T> = TODO()
    fun contains(key: String): Boolean = false
    fun remove(key: String): Any? = null
    fun keys(): Set<String> = emptySet()
}
