package androidx.media3.exoplayer.offline

open class DefaultDownloaderFactory(
    cacheDataSourceFactory: androidx.media3.datasource.cache.CacheDataSource.Factory,
    executor: java.util.concurrent.Executor,
) : DownloaderFactory()

