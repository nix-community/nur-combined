package androidx.media3.exoplayer.offline

open class DownloadService(
    val foregroundNotificationId: Int,
    val foregroundNotificationUpdateInterval: Long,
    val channelId: String?,
    val channelNameResourceId: Int,
    val channelDescriptionResourceId: Int
) : android.app.Service() {
    /* Subclasses provide these; the port's DownloadService must expose them as overridable. */
    open fun getDownloadManager(): androidx.media3.exoplayer.offline.DownloadManager =
        throw NotImplementedError()

    open fun getScheduler(): androidx.media3.exoplayer.scheduler.Scheduler? = null

    open fun getForegroundNotification(
        downloads: MutableList<Download>,
        notMetRequirements: Int,
    ): Any = Any()

    open fun onDownloadChanged(
        downloadManager: Any?,
        download: Download,
        finalState: Any?,
    ) {}

    open fun onDownloadRemoved(downloadManager: Any?, download: Download) {}

    companion object {
        @JvmStatic fun sendRemoveDownload(context: android.content.Context, clazz: Class<out DownloadService>, id: String, foreground: Boolean) {}
        @JvmStatic fun sendAddDownload(context: android.content.Context, clazz: Class<out DownloadService>, downloadRequest: DownloadRequest, stopReason: Int, foreground: Boolean) {}

        @JvmStatic fun sendAddDownload(context: android.content.Context, clazz: Class<out DownloadService>, downloadRequest: DownloadRequest, foreground: Boolean) {}
        @JvmStatic fun sendSetStopReason(context: android.content.Context, clazz: Class<out DownloadService>, id: String, stopReason: Int, foreground: Boolean) {}
        @JvmStatic fun sendRemoveAllDownloads(context: android.content.Context, clazz: Class<out DownloadService>, foreground: Boolean) {}
    }
}
