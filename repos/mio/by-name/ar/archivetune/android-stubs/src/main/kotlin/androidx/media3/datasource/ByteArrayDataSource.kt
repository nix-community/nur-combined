package androidx.media3.datasource

import android.net.Uri

/* media3's in-memory DataSource, used by modules that serve an inline manifest. */
open class ByteArrayDataSource(private val data: ByteArray) : DataSource {
    private var position = 0
    private var opened = false

    override fun addTransferListener(transferListener: TransferListener) {}

    override fun open(dataSpec: DataSpec): Long {
        position = 0
        opened = true
        return data.size.toLong()
    }

    override fun read(buffer: ByteArray, offset: Int, length: Int): Int {
        if (!opened) return -1
        if (position >= data.size) return -1
        val count = minOf(length, data.size - position)
        System.arraycopy(data, position, buffer, offset, count)
        position += count
        return count
    }

    override fun getUri(): Uri? = null

    override fun close() {
        opened = false
    }

    override fun getResponseHeaders(): Map<String, List<String>> = emptyMap()
}
