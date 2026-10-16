package coil3

import coil3.disk.DiskCache
import coil3.request.CachePolicy
import coil3.request.ImageRequest
import coil3.request.ImageResult
import coil3.request.SuccessResult
import coil3.request.ErrorResult
import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

fun ImageLoader(context: Any?): ImageLoader = ImageLoader.Builder(context).build()

val Context.imageLoader: ImageLoader get() = ImageLoader(this)

open class ComponentRegistry {
    open class Builder {
        fun add(interceptor: Any) = this
    }
}

open class ImageLoader {
    open suspend fun execute(request: ImageRequest): ImageResult = withContext(Dispatchers.IO) {
        val data = request.data
        try {
            val loaded = DesktopImageLoader.load(data)
            if (loaded != null) {
                SuccessResult(Image(imageBitmap = loaded.imageBitmap, bitmap = loaded.bitmap), request)
            } else {
                ErrorResult(Image(), request, RuntimeException("Could not load image: $data"))
            }
        } catch (e: Throwable) {
            ErrorResult(Image(), request, e)
        }
    }

    /* Upstream reads these off an ImageLoader instance (cache maintenance screen). */
    open val diskCache: DiskCache? = null

    open val memoryCache: coil3.memory.MemoryCache? = null

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
