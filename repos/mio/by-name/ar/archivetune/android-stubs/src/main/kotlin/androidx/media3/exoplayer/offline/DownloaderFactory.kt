package androidx.media3.exoplayer.offline

/* media3's factory for creating downloaders from a request. */
open class DownloaderFactory : Downloader.Factory {
    override fun createDownloader(request: DownloadRequest): Downloader = object : Downloader {
        override fun download(progressListener: Downloader.ProgressListener?) {}
        override fun cancel() {}
        override fun remove() {}
        override fun getProgress(): DownloadProgress = DownloadProgress()
    }

    companion object { }
}
