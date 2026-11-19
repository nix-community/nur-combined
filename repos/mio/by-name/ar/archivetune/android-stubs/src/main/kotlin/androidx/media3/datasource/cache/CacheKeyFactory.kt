package androidx.media3.datasource.cache

import androidx.media3.datasource.DataSpec

/* media3's per-request cache key hook. */
fun interface CacheKeyFactory {
    fun getKey(dataSpec: DataSpec): String
}
