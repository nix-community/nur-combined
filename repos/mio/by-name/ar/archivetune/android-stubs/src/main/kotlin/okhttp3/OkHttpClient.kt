package okhttp3
import java.util.concurrent.TimeUnit

open class OkHttpClient {
    open class Builder {
        fun connectTimeout(timeout: Long, unit: TimeUnit): Builder = this
        fun readTimeout(timeout: Long, unit: TimeUnit): Builder = this
        fun writeTimeout(timeout: Long, unit: TimeUnit): Builder = this
        fun retryOnConnectionFailure(retryOnConnectionFailure: Boolean): Builder = this
        fun build(): OkHttpClient = OkHttpClient()
    }
    companion object { }
}
