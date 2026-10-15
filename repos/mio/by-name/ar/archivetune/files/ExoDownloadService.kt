package moe.rukamori.archivetune.playback

import androidx.media3.exoplayer.offline.DownloadService

open class ExoDownloadService : DownloadService() {
    companion object {
        const val CHANNEL_ID = "download"
        const val NOTIFICATION_ID = 1
        const val JOB_ID = 1
    }
}
