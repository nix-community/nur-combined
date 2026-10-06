package androidx.lifecycle

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

open class SavedStateHandle {
    private val flows = mutableMapOf<String, MutableStateFlow<Any?>>()
    operator fun <T> get(key: String): T? = null
    operator fun <T> set(key: String, value: T?) {}
    
    @Suppress("UNCHECKED_CAST")
    fun <T> getStateFlow(key: String, initialValue: T): StateFlow<T> {
        return flows.getOrPut(key) { MutableStateFlow(initialValue) } as StateFlow<T>
    }
    
    fun contains(key: String): Boolean = false
    fun remove(key: String): Any? = null
    fun keys(): Set<String> = emptySet()
}
