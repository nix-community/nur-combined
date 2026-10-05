package androidx.media3.datasource.cache

class CacheSpan : Comparable<CacheSpan> {
    val lastTouchTimestamp: Long = 0L
    val length: Long = 0L
    override fun compareTo(other: CacheSpan): Int = 0
}
