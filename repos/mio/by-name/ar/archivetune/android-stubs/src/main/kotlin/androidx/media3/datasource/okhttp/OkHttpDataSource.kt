package androidx.media3.datasource.okhttp

import androidx.media3.datasource.DataSource

open class OkHttpDataSource : DataSource {
    class Factory(client: Any) : DataSource.Factory {
        override fun createDataSource(): DataSource = OkHttpDataSource()
    }

    override fun addTransferListener(transferListener: androidx.media3.datasource.TransferListener) {}

    override fun open(dataSpec: androidx.media3.datasource.DataSpec): Long = 0L

    override fun read(buffer: ByteArray, offset: Int, length: Int): Int = -1

    override fun getUri(): android.net.Uri? = null

    override fun close() {}

    override fun getResponseHeaders(): Map<String, List<String>> = emptyMap()
}
