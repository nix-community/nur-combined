package okhttp3

interface Interceptor {
    fun intercept(chain: Chain): Response
    
    interface Chain {
        fun request(): Request
        fun proceed(request: Request): Response
        fun call(): Call
    }
}
