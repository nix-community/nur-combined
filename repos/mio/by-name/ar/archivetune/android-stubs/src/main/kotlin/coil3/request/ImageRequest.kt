package coil3.request

import android.content.Context

open class ImageRequest {
    val networkCachePolicy = CachePolicy()
    val data: Any? = null
    fun newBuilder(): Builder = Builder(null)

    class Builder(context: Context?) {
        fun data(data: Any?): Builder = this
        fun size(width: Int, height: Int): Builder = this
        fun size(size: Int): Builder = this
        fun allowHardware(allow: Boolean): Builder = this
        fun memoryCacheKey(key: String): Builder = this
        fun diskCacheKey(key: String): Builder = this
        fun build(): ImageRequest = ImageRequest()
    }

    class CachePolicy {
        val readEnabled: Boolean = false
    }
}
