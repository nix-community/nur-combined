package moe.rukamori.archivetune.utils

object AppUpdateInstaller {
    data class Progress(val bytesDownloaded: Long, val totalBytes: Long) {
        val fraction: Float
            get() = if (totalBytes <= 0L) 0f else (bytesDownloaded.toFloat() / totalBytes)
    }

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
