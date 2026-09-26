package androidx.media3.exoplayer.offline

open class DownloadRequest(val id: String, val uri: android.net.Uri) {
    val mimeType: String? = null
    val keySetId: ByteArray? = null
    val customCacheKey: String? = null
    val data: ByteArray? = null
    val streamKeys: List<Any> = emptyList()
}
