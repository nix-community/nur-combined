package okhttp3


abstract class ResponseBody : java.io.Closeable {
    fun byteStream(): java.io.InputStream = TODO()
    override fun close() {}
}

