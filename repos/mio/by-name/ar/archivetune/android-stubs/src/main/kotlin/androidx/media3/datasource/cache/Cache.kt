package androidx.media3.datasource.cache

import java.io.File
import java.util.NavigableSet

/*
 * media3's Cache is a Java interface: AppModule implements it anonymously (`) : Cache {`),
 * which only compiles for an interface, and it overrides these members, which must therefore
 * not be final. Every member carries a default body so an implementation need not restate all
 * of them. Kotlin callers still reach the getter forms via the extensions injected by
 * fix_theme.py.
 */
interface Cache {
    fun getUid(): Long = 0L

    fun getKeys(): NavigableSet<String> = java.util.TreeSet()

    fun getCacheSpace(): Long = 0L

    fun addListener(key: String, listener: Listener) {}

    fun removeListener(key: String, listener: Listener) {}

    fun getCachedSpans(key: String): NavigableSet<CacheSpan> = java.util.TreeSet()

    fun getCachedLength(key: String, position: Long, length: Long): Long = 0L

    fun getCachedBytes(key: String, position: Long, length: Long): Long = 0L

    fun getContentMetadata(key: String): ContentMetadata = ContentMetadata()

    fun applyContentMetadataMutations(key: String, mutations: ContentMetadataMutations) {}

    fun isCached(key: String, position: Long, length: Long): Boolean = false

    fun startReadWrite(key: String, position: Long, length: Long): CacheSpan = CacheSpan()

    fun startReadWriteNonBlocking(key: String, position: Long, length: Long): CacheSpan? = null

    fun startFile(key: String, position: Long, maxLength: Long): File = File("/tmp")

    fun commitFile(file: File, length: Long) {}

    fun releaseHoleSpan(holeSpan: CacheSpan) {}

    fun removeSpan(span: CacheSpan) {}

    fun release() {}

    fun removeResource(key: String): Boolean = false

    fun removeResource(key: String, span: CacheSpan?): Boolean = false

    interface Listener {
        fun onSpanAdded(cache: Cache, span: CacheSpan) {}

        fun onSpanRemoved(cache: Cache, span: CacheSpan) {}

        fun onSpanTouched(cache: Cache, oldSpan: CacheSpan, newSpan: CacheSpan) {}
    }
}

/*
 * Kotlin callers (AppModule among them) read the Java getters as properties; these extensions
 * are what fix_theme.py imports where used.
 */
val Cache.uid: Long get() = getUid()

val Cache.keys: java.util.NavigableSet<String> get() = getKeys()

val Cache.cacheSpace: Long get() = getCacheSpace()
