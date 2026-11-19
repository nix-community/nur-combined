package androidx.media3.datasource.cache

import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DataSpec
import androidx.media3.datasource.TransferListener

open class CacheDataSource {
    class Factory : DataSource.Factory {
        fun setCache(cache: Any?): Factory = this
        fun setUpstreamDataSourceFactory(factory: Any?): Factory = this
        fun setCacheWriteDataSinkFactory(factory: Any?): Factory = this
        fun setCacheKeyFactory(factory: Any?): Factory = this
        fun setFlags(flags: Int): Factory = this
        override fun createDataSource(): DataSource = EmptyDataSource
    }
    companion object {
        const val FLAG_IGNORE_CACHE_ON_ERROR = 1
    }
}

private object EmptyDataSource : DataSource {
    override fun addTransferListener(transferListener: TransferListener) {}
    override fun open(dataSpec: DataSpec): Long = 0L
    override fun read(buffer: ByteArray, offset: Int, length: Int): Int = -1
    override fun getUri(): android.net.Uri? = null
    override fun close() {}
    override fun getResponseHeaders(): Map<String, List<String>> = emptyMap()
}
