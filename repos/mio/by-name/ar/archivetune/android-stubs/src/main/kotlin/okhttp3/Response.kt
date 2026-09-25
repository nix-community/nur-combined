package okhttp3

open class Response : java.io.Closeable {
    open val body: ResponseBody = TODO()
    open val isSuccessful: Boolean = false
    open val code: Int = 200
    
    fun header(name: String, defaultValue: String? = null): String? = null
    fun newBuilder(): Builder = Builder()
    
    override fun close() {}
    
    open class Builder {
        fun body(body: ResponseBody): Builder = this
        fun build(): Response = Response()
    }
}
