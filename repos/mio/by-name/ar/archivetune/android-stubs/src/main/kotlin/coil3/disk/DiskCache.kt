package coil3.disk
import java.io.File
open class DiskCache {
    val maxSize: Long = 0L
    val directory: File = File("")
    open class Builder {
        fun build(): DiskCache = DiskCache()
        fun directory(dir: File) = this
        fun maxSizePercent(percent: Double) = this
        fun maxSizeBytes(size: Long) = this
    }
}
