package androidx.media3.exoplayer.offline

/*
 * media3's Downloader is an interface (ResumingDownloader implements it as `) : Downloader {`),
 * and the app reaches `factory.createDownloader(request)` plus Downloader.ProgressListener.
 */
interface Downloader {
    fun download(progressListener: ProgressListener?)

    fun cancel()

    fun remove()

    fun getProgress(): DownloadProgress = DownloadProgress()

    interface ProgressListener {
        /* media3 reports progress both as a struct and as three positional values. */
        fun onProgress(progress: DownloadProgress) {}

        fun onProgress(
            contentLength: Long,
            bytesDownloaded: Long,
            percentDownloaded: Float,
        ) {}

        fun onInitialized(request: DownloadRequest) {}
    }

    interface Factory {
        fun createDownloader(request: DownloadRequest): Downloader
    }
}
