package androidx.media3.datasource.cache

open class CacheDataSource {
    class Factory {
        fun setCache(cache: Any): Factory = this
        fun setUpstreamDataSourceFactory(factory: Any): Factory = this
        fun setCacheWriteDataSinkFactory(factory: Any): Factory = this
        fun setCacheKeyFactory(factory: Any): Factory = this
        fun setFlags(flags: Int): Factory = this
        fun createDataSource(): Any = Any()
    }
    companion object {
        const val FLAG_IGNORE_CACHE_ON_ERROR = 1
    }
}
