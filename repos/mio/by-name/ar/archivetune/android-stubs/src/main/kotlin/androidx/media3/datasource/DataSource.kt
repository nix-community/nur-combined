package androidx.media3.datasource

import android.net.Uri

/*
 * media3's DataSource is an interface that upstream *implements* (ChunkedDataSource), so a
 * stub class made every `override fun open(...)`/`read(...)` fail with "overrides nothing".
 */
interface DataSource {
    fun addTransferListener(transferListener: TransferListener)

    fun open(dataSpec: DataSpec): Long

    fun read(buffer: ByteArray, offset: Int, length: Int): Int

    fun getUri(): Uri?

    fun close()

    fun getResponseHeaders(): Map<String, List<String>>

    interface Factory {
        fun createDataSource(): DataSource
    }
}
