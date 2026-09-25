package coil3

import coil3.disk.DiskCache
import coil3.request.CachePolicy

open class ComponentRegistry {
    open class Builder {
        fun add(interceptor: Any) = this
    }
}

open class ImageLoader {
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
