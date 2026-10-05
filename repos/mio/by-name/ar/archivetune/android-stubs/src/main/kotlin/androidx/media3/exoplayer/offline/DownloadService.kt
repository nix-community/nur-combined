package androidx.media3.exoplayer.offline

open class DownloadService(
    val foregroundNotificationId: Int,
    val foregroundNotificationUpdateInterval: Long,
    val channelId: String?,
    val channelNameResourceId: Int,
    val channelDescriptionResourceId: Int
) : android.app.Service() {
    companion object {
        @JvmStatic fun sendRemoveDownload(context: android.content.Context, clazz: Class<out DownloadService>, id: String, foreground: Boolean) {}
        @JvmStatic fun sendAddDownload(context: android.content.Context, clazz: Class<out DownloadService>, downloadRequest: DownloadRequest, foreground: Boolean) {}
        @JvmStatic fun sendSetStopReason(context: android.content.Context, clazz: Class<out DownloadService>, id: String, stopReason: Int, foreground: Boolean) {}
        @JvmStatic fun sendRemoveAllDownloads(context: android.content.Context, clazz: Class<out DownloadService>, foreground: Boolean) {}
    }
}
