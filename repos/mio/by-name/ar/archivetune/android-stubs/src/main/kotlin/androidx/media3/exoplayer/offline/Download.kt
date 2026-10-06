package androidx.media3.exoplayer.offline

open class Download(
    val request: DownloadRequest = DownloadRequest("", android.net.Uri.EMPTY),
    val state: Int = 0,
    val startTimeMs: Long = 0L,
    val updateTimeMs: Long = 0L,
    val contentLength: Long = 0L,
    val stopReason: Int = 0,
    val failureReason: Int = 0,
    val bytesDownloaded: Long = 0L,
    @get:JvmName("percentDownloadedValue") val percentDownloaded: Float = 0f,
) {
    /*
     * Upstream calls the Java-style getter `download.getPercentDownloaded()` while the rest of
     * the app reads the property; both would produce the same JVM signature, so the property's
     * getter is renamed instead.
     */
    fun getPercentDownloaded(): Float = percentDownloaded

    @Target(
        AnnotationTarget.VALUE_PARAMETER,
        AnnotationTarget.FIELD,
        AnnotationTarget.PROPERTY,
        AnnotationTarget.FUNCTION,
    )
    @Retention(AnnotationRetention.RUNTIME)
    annotation class State

    companion object {
        const val STATE_QUEUED = 0
        const val STATE_STOPPED = 1
        const val STATE_DOWNLOADING = 2
        const val STATE_COMPLETED = 3
        const val STATE_FAILED = 4
        const val STATE_REMOVING = 5
        const val STATE_RESTARTING = 7
        const val STOP_REASON_NONE = 0
        const val FAILURE_REASON_NONE = 0
    }
}
