package androidx.media3.common

open class MediaItem(
    open val mediaId: String = "",
    open val mediaMetadata: MediaMetadata = MediaMetadata(),
    open val requestMetadata: RequestMetadata = RequestMetadata(),
    open val localConfiguration: LocalConfiguration? = null,
) {
    data class RequestMetadata(
        val mediaUri: android.net.Uri? = null,
        val extras: android.os.Bundle? = null,
    ) {
        class Builder {
            private var mediaUri: android.net.Uri? = null
            private var extras: android.os.Bundle? = null

            fun setMediaUri(uri: android.net.Uri?): Builder = apply { this.mediaUri = uri }
            fun setExtras(extras: android.os.Bundle?): Builder = apply { this.extras = extras }
            fun build(): RequestMetadata = RequestMetadata(mediaUri = mediaUri, extras = extras)
        }
    }

    data class LocalConfiguration(
        val uri: android.net.Uri,
        val mimeType: String? = null,
        val tag: Any? = null,
        val customCacheKey: String? = null,
    )

    class Builder {
        private var mediaId: String = ""
        private var uri: android.net.Uri? = null
        private var mimeType: String? = null
        private var tag: Any? = null
        private var customCacheKey: String? = null
        private var mediaMetadata: MediaMetadata = MediaMetadata()
        private var requestMetadata: RequestMetadata = RequestMetadata()

        fun setUri(uri: android.net.Uri): Builder = apply { this.uri = uri }
        fun setUri(uri: String): Builder = apply { this.uri = android.net.Uri.parse(uri) }
        fun setMediaId(id: String): Builder = apply { this.mediaId = id }
        /* Upstream tags items with its own metadata model and sets an OkHttp cache key. */
        fun setTag(tag: Any?): Builder = apply { this.tag = tag }
        fun setCustomCacheKey(cacheKey: String?): Builder = apply { this.customCacheKey = cacheKey }
        fun setClipStartPositionMs(clipStartPositionMs: Long): Builder = this
        fun setClipEndPositionMs(clipEndPositionMs: Long): Builder = this
        fun setMediaMetadata(meta: MediaMetadata): Builder = apply { this.mediaMetadata = meta }
        fun setRequestMetadata(meta: RequestMetadata): Builder = apply { this.requestMetadata = meta }
        fun setMimeType(mimeType: String?): Builder = apply { this.mimeType = mimeType }

        fun build(): MediaItem {
            val effUri = uri ?: android.net.Uri.parse(mediaId)
            val localConfig = LocalConfiguration(
                uri = effUri,
                mimeType = mimeType,
                tag = tag,
                customCacheKey = customCacheKey,
            )
            return MediaItem(
                mediaId = mediaId.ifEmpty { uri?.toString().orEmpty() },
                mediaMetadata = mediaMetadata,
                requestMetadata = requestMetadata,
                localConfiguration = localConfig,
            )
        }
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is MediaItem) return false
        return mediaId == other.mediaId
    }

    override fun hashCode(): Int = mediaId.hashCode()

    override fun toString(): String = "MediaItem(id=$mediaId)"

    companion object {
        val EMPTY: MediaItem = MediaItem()
        fun fromUri(uri: android.net.Uri): MediaItem = Builder().setUri(uri).build()
        fun fromUri(uri: String): MediaItem = Builder().setUri(uri).build()
    }
}
