package androidx.media3.exoplayer.offline

/* Upstream builds the failure notification through this helper. */
open class DownloadNotificationHelper(
    context: Any? = null,
    channelId: String? = null,
    channelNameResourceId: Int = 0,
) {
    open fun buildDownloadFailedNotification(
        context: Any?,
        smallIconResourceId: Int,
        download: Download?,
        errorMessage: String?,
    ): Any = Any()

    open fun buildProgressNotification(
        context: Any?,
        download: Download,
        notMetRequirements: Int,
    ): Any = Any()

    open fun buildDownloadCompletedNotification(
        context: Any?,
        download: Download,
    ): Any = Any()
}
