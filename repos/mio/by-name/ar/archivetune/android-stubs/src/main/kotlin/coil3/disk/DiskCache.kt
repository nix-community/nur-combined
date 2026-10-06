package coil3.disk

import java.io.File

open class DiskCache {
    val maxSize: Long = 0L
    val directory: File = File("")

    /* Upstream clears the on-disk cache and then asserts it is empty. */
    open val size: Long = 0L

    open fun clear() {}

    open class Builder {
        fun build(): DiskCache = DiskCache()
        fun directory(dir: File) = this
        fun maxSizePercent(percent: Double) = this
        fun maxSizeBytes(size: Long) = this
    }
}
