/*
 * ArchiveTune (2026)
 * © Rukamori — github.com/rukamori
 * GPL-3.0 License | Contributors: see git history
 * Do not remove or alter this notice. - Per GPL-3.0 Section 4 & Section 5
 */

package moe.rukamori.archivetune.playlistexport

import android.net.Uri
import androidx.compose.runtime.Immutable
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.flowOn
import moe.rukamori.archivetune.repository.PlaylistExportRepository
import java.io.IOException
import javax.inject.Inject

@Immutable
data class ExportablePlaylist(
    val id: String,
    val name: String,
    val songCount: Int,
    val suggestedFileName: String,
)

class ObserveExportablePlaylistsUseCase
    @Inject
    constructor(
        private val repository: PlaylistExportRepository,
    ) {
        operator fun invoke(): Flow<List<ExportablePlaylist>> =
            repository
                .observePlaylists()
                .map { playlists ->
                    playlists
                        .asReversed()
                        .asSequence()
                        .filter { playlist -> playlist.songCount > 0 }
                        .map { playlist ->
                            val name = playlist.playlist.name
                            ExportablePlaylist(
                                id = playlist.id,
                                name = name,
                                songCount = playlist.songCount,
                                suggestedFileName = name.toCsvFileName(),
                            )
                        }.toList()
                }.flowOn(Dispatchers.Default)
    }

class ExportPlaylistAsCsvUseCase
    @Inject
    constructor(
        private val repository: PlaylistExportRepository,
    ) {
        suspend operator fun invoke(
            playlistId: String,
            destination: Uri,
        ) {
            val songs = repository.loadPlaylistSongs(playlistId)
            if (songs.isEmpty()) throw IOException("Playlist has no songs")

            val records =
                sequence {
                    yield(CSV_HEADER)
                    songs.forEach { playlistSong ->
                        val song = playlistSong.song
                        yield(
                            listOf(
                                song.song.title,
                                song.artists.joinToString(separator = "; ") { artist -> artist.name },
                                song.album?.title ?: song.song.albumName.orEmpty(),
                                song.song.id,
                            ),
                        )
                    }
                }
            repository.writeCsv(destination = destination, records = records)
        }

        private companion object {
            val CSV_HEADER = listOf("Title", "Artist", "Album", "Media ID")
        }
    }

private val CSV_FILE_NAME_FORBIDDEN_CHARACTERS = Regex("""[\\/:*?"<>|\p{Cntrl}]""")

private fun String.toCsvFileName(): String {
    val safeBaseName =
        trim()
            .replace(CSV_FILE_NAME_FORBIDDEN_CHARACTERS, "_")
            .trimEnd('.', ' ')
            .takeCodePoints(MAX_CSV_FILE_NAME_LENGTH)
            .ifBlank { DEFAULT_CSV_FILE_NAME }
    return "$safeBaseName.csv"
}

private fun String.takeCodePoints(maxCodePoints: Int): String {
    val count = codePointCount(0, length)
    if (count <= maxCodePoints) return this
    return substring(0, offsetByCodePoints(0, maxCodePoints))
}

private const val MAX_CSV_FILE_NAME_LENGTH = 96
private const val DEFAULT_CSV_FILE_NAME = "playlist"
