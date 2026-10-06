package androidx.media3.exoplayer.offline

open class DownloadManager {
    /* ExoDownloadService implements this to react to download state changes. */
    interface Listener {
        fun onInitialized(downloadManager: DownloadManager) {}

        fun onDownloadChanged(
            downloadManager: DownloadManager,
            download: Download,
            finalException: Exception?,
        ) {}

        fun onDownloadRemoved(downloadManager: DownloadManager, download: Download) {}

        fun onIdle(downloadManager: DownloadManager) {}
    }

    /* Upstream iterates the active downloads (ExoDownloadService). */
    val currentDownloads: List<Download> = emptyList()

    fun removeAllDownloads() {}

    fun getDownload(id: String): Download? = null

    fun getDownloads(): List<Download> = emptyList()

    fun addDownload(request: DownloadRequest): Int = 0

    fun removeDownload(id: String) {}

    fun resumeDownloads() {}

    fun pauseDownloads() {}

    fun getDownloadIndex(): Any = Any()

    companion object { }
}
