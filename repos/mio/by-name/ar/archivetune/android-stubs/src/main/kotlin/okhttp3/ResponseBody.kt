package okhttp3
import okio.BufferedSource

open class ResponseBody : java.io.Closeable {
    open fun contentType(): Any? = null
    open fun contentLength(): Long = 0L
    open fun source(): BufferedSource = TODO()
    open fun byteStream(): MyInputStream = TODO()
    override fun close() {}
}

abstract class MyInputStream : java.io.InputStream(), java.io.Closeable {
    override fun read(b: ByteArray): Int = -1
}
