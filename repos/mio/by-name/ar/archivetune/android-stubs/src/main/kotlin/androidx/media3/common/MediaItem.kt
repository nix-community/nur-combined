package androidx.media3.common

open class MediaItem {
    open val mediaId: String = ""
    open val mediaMetadata: MediaMetadata = MediaMetadata()
    open val requestMetadata: RequestMetadata = RequestMetadata()
    open val localConfiguration: LocalConfiguration? = null

    data class RequestMetadata(val mediaUri: android.net.Uri? = null, val extras: android.os.Bundle? = null) {
        class Builder {
            fun setMediaUri(uri: android.net.Uri?): Builder = this
            fun setExtras(extras: android.os.Bundle?): Builder = this
            fun build(): RequestMetadata = RequestMetadata()
        }
    }

    data class LocalConfiguration(
        val uri: android.net.Uri,
        val mimeType: String? = null,
        val tag: Any? = null,
        val customCacheKey: String? = null,
    )

    class Builder {
        fun setUri(uri: android.net.Uri): Builder = this
        fun setUri(uri: String): Builder = this
        fun setMediaId(id: String): Builder = this
        /* Upstream tags items with its own metadata model and sets an OkHttp cache key. */
        fun setTag(tag: Any?): Builder = this
        fun setCustomCacheKey(cacheKey: String?): Builder = this
        fun setClipStartPositionMs(clipStartPositionMs: Long): Builder = this
        fun setClipEndPositionMs(clipEndPositionMs: Long): Builder = this
        fun setMediaMetadata(meta: MediaMetadata): Builder = this
        fun setRequestMetadata(meta: RequestMetadata): Builder = this
        fun setMimeType(mimeType: String?): Builder = this
        fun build(): MediaItem = MediaItem()
    }

    companion object {
        val EMPTY: MediaItem = MediaItem()
        fun fromUri(uri: android.net.Uri): MediaItem = MediaItem()
        fun fromUri(uri: String): MediaItem = MediaItem()
    }
}
