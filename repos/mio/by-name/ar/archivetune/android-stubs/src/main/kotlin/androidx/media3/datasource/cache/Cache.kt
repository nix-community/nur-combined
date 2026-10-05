package androidx.media3.datasource.cache

open class Cache {
    val keys: Set<String> = emptySet()
    val cacheSpace: Long = 0L
    
    fun getCachedSpans(key: String): java.util.NavigableSet<CacheSpan> = java.util.TreeSet()
    fun removeResource(key: String) {}
    fun getContentMetadata(key: String): Any = Any()
    fun applyContentMetadataMutations(key: String, mutations: Any) {}
    fun isCached(key: String, position: Long, length: Long): Boolean = false
}
