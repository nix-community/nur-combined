package moe.rukamori.archivetune.utils

object AppUpdateInstaller {
    fun createInstallIntent(context: android.content.Context, file: java.io.File): android.content.Intent =
        android.content.Intent()

    data class Progress(val bytesDownloaded: Long, val totalBytes: Long) {
        val downloadedBytes: Long get() = bytesDownloaded

        val fraction: Float
            get() = if (totalBytes <= 0L) 0f else (bytesDownloaded.toFloat() / totalBytes)
    }

    suspend fun download(
        context: android.content.Context?,
        url: String,
        onProgress: (Progress) -> Unit = {},
    ): java.io.File = java.io.File(url.substringAfterLast('/'))

    suspend fun install(url: String, onProgress: (Progress) -> Unit): Boolean { return false }

    /*
     * Upstream calls AppUpdateInstaller.downloadAndInstall(context, url) { progress -> ... }
     * .onSuccess { ... }, so the result must be a Result (not a Boolean).
     */
    suspend fun downloadAndInstall(
        context: android.content.Context?,
        url: String,
        onProgress: (Progress) -> Unit = {},
    ): Result<Unit> = Result.success(Unit)
}
