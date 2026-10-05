package coil3

import coil3.disk.DiskCache
import coil3.request.CachePolicy
import coil3.request.ImageRequest
import coil3.request.ImageResult
import android.content.Context

fun ImageLoader(context: Any?): ImageLoader = ImageLoader.Builder(context).build()

val Context.imageLoader: ImageLoader get() = ImageLoader(this)

open class ComponentRegistry {
    open class Builder {
        fun add(interceptor: Any) = this
    }
}

open class ImageLoader {
    open suspend fun execute(request: ImageRequest): ImageResult = throw NotImplementedError()
    open class Builder(context: Any?) {
        fun crossfade(enable: Boolean) = this
        fun allowHardware(enable: Boolean) = this
        fun diskCache(cache: DiskCache?) = this
        fun diskCachePolicy(policy: CachePolicy) = this
        fun components(block: ComponentRegistry.Builder.() -> Unit) = this
        fun build(): ImageLoader = ImageLoader()
    }
    companion object { }
}
