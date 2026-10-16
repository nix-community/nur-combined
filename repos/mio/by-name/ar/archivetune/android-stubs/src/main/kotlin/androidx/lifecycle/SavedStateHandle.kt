package androidx.lifecycle

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

open class SavedStateHandle(initialState: Map<String, Any?> = emptyMap()) {
    private val values = mutableMapOf<String, Any?>().apply { putAll(initialState) }
    private val flows = mutableMapOf<String, MutableStateFlow<Any?>>()

    @Suppress("UNCHECKED_CAST")
    operator fun <T> get(key: String): T? {
        val v = values[key]
        if (v != null) return v as? T
        val fallback = when (key) {
            "playlistId", "albumId", "artistId", "browseId", "id", "top", "playlist", "newsId" -> ("" as T)
            else -> null
        }
        if (fallback != null) {
            println("[SavedStateHandle] key '$key' missing in values, returning fallback: '$fallback' (known keys: ${values.keys})")
        }
        return fallback
    }

    operator fun <T> set(key: String, value: T?) {
        println("[SavedStateHandle] set '$key' = '$value'")
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
