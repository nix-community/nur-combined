package moe.rukamori.archivetune.playback

import androidx.media3.datasource.cache.Cache
import androidx.media3.exoplayer.offline.Download
import androidx.media3.exoplayer.offline.DownloadManager
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map

/*
 * Upstream's DownloadUtil owns the media3 offline DownloadManager and the two media3
 * caches. The port keeps those members so DownloadRepository, StorageLocationRepository,
 * ExoDownloadService and the UI still resolve, but owns no real cache yet: nothing is
 * ever cached or downloaded on the desktop build.
 */
class DownloadUtil {
    val downloadCache: Cache = TODO("desktop port has no download cache")

    val playerCache: Cache = TODO("desktop port has no player cache")

    val downloadManager: DownloadManager = DownloadManager()

    val downloads: StateFlow<Map<String, Download>> = MutableStateFlow(emptyMap())

    fun getDownload(id: String): Flow<Download?> = downloads.map { it[id] }
}
