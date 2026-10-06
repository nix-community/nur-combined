package coil3.request

import coil3.Image
import coil3.size.Size

/*
 * Coil 3's request model. The real coil3 JVM artifact cannot be used here: upstream
 * targets Android and uses Android-only coil3 APIs (allowHardware,
 * LocalPlatformContext.imageLoader), which the JVM publication does not ship. The
 * port keeps the builder chain the app calls, loosely typed.
 */
class ImageRequest private constructor() {
    /* Upstream reads these off a request in its OkHttp interceptor. */
    val data: Any? = null

    val networkCachePolicy: CachePolicy = CachePolicy()

    val memoryCachePolicy: CachePolicy = CachePolicy()

    val diskCachePolicy: CachePolicy = CachePolicy()

    fun newBuilder(): Builder = Builder()

    class Builder(val data: Any? = null) {
        fun data(data: Any?): Builder = this

        fun size(size: Size): Builder = this
        fun size(size: Int): Builder = this

        fun size(width: Int, height: Int): Builder = this

        fun allowHardware(enable: Boolean): Builder = this

        fun allowRgb565(enable: Boolean): Builder = this

        fun crossfade(enable: Boolean): Builder = this

        fun crossfade(durationMillis: Int): Builder = this

        fun memoryCachePolicy(policy: Any): Builder = this

        fun diskCachePolicy(policy: Any): Builder = this

        fun networkCachePolicy(policy: Any): Builder = this

        fun memoryCacheKey(key: String?): Builder = this

        fun diskCacheKey(key: String?): Builder = this

        fun placeholder(painter: Any?): Builder = this

        fun error(painter: Any?): Builder = this

        fun fallback(painter: Any?): Builder = this

        fun listener(listener: Any?): Builder = this

        fun transformations(vararg transformations: Any): Builder = this

        fun build(): ImageRequest = ImageRequest()

        companion object {
            fun from(context: Any): Builder = Builder()
        }
    }

    companion object {
        val DEFAULT = ImageRequest()
    }
}
