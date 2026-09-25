package okhttp3

open class Response {
    open val body: ResponseBody? = null
    open val isSuccessful: Boolean = false
    open val code: Int = 200
    
    fun header(name: String, defaultValue: String? = null): String? = null
    fun newBuilder(): Builder = Builder()
    
    open class Builder {
        fun body(body: ResponseBody): Builder = this
        fun build(): Response = Response()
    }
}
