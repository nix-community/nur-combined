package androidx.lifecycle

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

open class SavedStateHandle {
    private val values = mutableMapOf<String, Any?>()
    private val flows = mutableMapOf<String, MutableStateFlow<Any?>>()

    @Suppress("UNCHECKED_CAST")
    operator fun <T> get(key: String): T? = values[key] as? T

    operator fun <T> set(key: String, value: T?) {
        values[key] = value
        flows[key]?.value = value
    }
    
    @Suppress("UNCHECKED_CAST")
    fun <T> getStateFlow(key: String, initialValue: T): StateFlow<T> {
        return flows.getOrPut(key) { MutableStateFlow(values[key] ?: initialValue) } as StateFlow<T>
    }
    
    fun contains(key: String): Boolean = values.containsKey(key)
    fun remove(key: String): Any? {
        val removed = values.remove(key)
        flows[key]?.value = null
        return removed
    }
    fun keys(): Set<String> = values.keys
}
