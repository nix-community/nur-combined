package okhttp3


open class Response : java.io.Closeable {
    val isSuccessful: Boolean = false
    val code: Int = 0
    val body: ResponseBody? = null
    override fun close() {}
}

