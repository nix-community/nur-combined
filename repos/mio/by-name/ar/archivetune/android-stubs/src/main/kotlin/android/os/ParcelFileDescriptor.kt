package android.os

/*
 * Upstream resolves content URIs through ContentResolver.openFileDescriptor and then reads
 * `descriptor.fileDescriptor`, so the stub must expose a real FileDescriptor rather than Any.
 */
open class ParcelFileDescriptor : java.io.Closeable {
    val fileDescriptor: java.io.FileDescriptor = java.io.FileDescriptor()

    val statSize: Long = 0L

    override fun close() {}

    companion object {
        @JvmStatic
        fun open(file: java.io.File, mode: Int): ParcelFileDescriptor = ParcelFileDescriptor()
    }
}
