package okhttp3

open class MediaType {
    companion object {
        @JvmStatic fun parse(string: String): MediaType? = MediaType()
    }
}
fun String.toMediaType(): MediaType = MediaType()

open class RequestBody {
    companion object {
        fun String.toRequestBody(contentType: MediaType? = null): RequestBody = RequestBody()
        @JvmStatic fun create(content: String, contentType: MediaType?): RequestBody = RequestBody()
    }
}

open class ResponseBody {
    fun string(): String = ""
    fun byteStream(): java.io.InputStream = java.io.ByteArrayInputStream(ByteArray(0))
}

class OkHttpClient {
    class Builder {
        fun build(): OkHttpClient = OkHttpClient()
        fun callTimeout(timeout: Long, unit: java.util.concurrent.TimeUnit): Builder = this
        fun readTimeout(timeout: Long, unit: java.util.concurrent.TimeUnit): Builder = this
        fun connectTimeout(timeout: Long, unit: java.util.concurrent.TimeUnit): Builder = this
    }
    fun newCall(request: Request): Call = Call()
}

class Request {
    class Builder {
        fun url(url: String): Builder = this
        fun get(): Builder = this
        fun post(body: RequestBody): Builder = this
        fun put(body: RequestBody): Builder = this
        fun delete(body: RequestBody? = null): Builder = this
        fun header(name: String, value: String): Builder = this
        fun addHeader(name: String, value: String): Builder = this
        fun removeHeader(name: String): Builder = this
        fun headers(headers: Headers): Builder = this
        fun build(): Request = Request()
    }
}

class Call {
    fun cancel() {}
    val isCanceled: Boolean = false
    fun enqueue(responseCallback: Callback) {}
    fun execute(): Response = Response()
}

class Response : java.io.Closeable {
    val body: ResponseBody? = null
    val code: Int = 0
    val isSuccessful: Boolean = true
    override fun close() {}
}

interface Interceptor {
    interface Chain {
        fun call(): Call
        fun request(): Request
        fun proceed(request: Request): Response
    }
    fun intercept(chain: Chain): Response
}

class Headers {
    companion object {
        fun Map<String, String>.toHeaders(): Headers = Headers()
    }
    class Builder {
        fun add(name: String, value: String): Builder = this
        fun build(): Headers = Headers()
    }
}

interface Dns {
    companion object {
        val SYSTEM: Dns = object : Dns {}
    }
}

interface Callback {
    fun onFailure(call: Call, e: java.io.IOException)
    fun onResponse(call: Call, response: Response)
}




fun ResponseBody.contentLength(): Long = 0L

fun OkHttpClient.Builder.callTimeout(timeout: Int, unit: java.util.concurrent.TimeUnit): OkHttpClient.Builder = this

