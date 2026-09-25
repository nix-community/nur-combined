package okhttp3
import okio.BufferedSource

open class ResponseBody {
    open fun contentType(): Any? = null
    open fun contentLength(): Long = 0L
    open fun source(): BufferedSource = TODO()
}
