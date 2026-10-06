package androidx.media3.exoplayer.offline

open class DownloadRequest(val id: String, val uri: android.net.Uri) {
    val mimeType: String? = null
    val keySetId: ByteArray? = null
    val customCacheKey: String? = null
    val data: ByteArray = ByteArray(0)
    val streamKeys: List<Any> = emptyList()

    class Builder(val id: String, val uri: android.net.Uri) {
        fun setCustomCacheKey(customCacheKey: String?) = this
        fun setData(data: ByteArray?) = this
        fun build() = DownloadRequest(id, uri)
    }
}
