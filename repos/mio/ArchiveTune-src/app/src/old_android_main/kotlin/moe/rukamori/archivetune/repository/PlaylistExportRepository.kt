/*
 * ArchiveTune (2026)
 * © Rukamori — github.com/rukamori
 * GPL-3.0 License | Contributors: see git history
 * Do not remove or alter this notice. - Per GPL-3.0 Section 4 & Section 5
 */

package moe.rukamori.archivetune.repository

import android.content.Context
import android.net.Uri
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.withContext
import moe.rukamori.archivetune.db.MusicDatabase
import moe.rukamori.archivetune.db.entities.Playlist
import moe.rukamori.archivetune.db.entities.PlaylistSong
import java.io.IOException
import java.io.Writer
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class PlaylistExportRepository
    @Inject
    constructor(
        @ApplicationContext private val context: Context,
        private val database: MusicDatabase,
    ) {
        fun observePlaylists(): Flow<List<Playlist>> =
            database
                .playlistsByCreateDateAsc()
                .flowOn(Dispatchers.IO)

        suspend fun loadPlaylistSongs(playlistId: String): List<PlaylistSong> =
            withContext(Dispatchers.IO) {
                database.getPlaylistSongs(playlistId)
            }

        suspend fun writeCsv(
            destination: Uri,
            records: Sequence<List<String>>,
        ) = withContext(Dispatchers.IO) {
            val writer =
                context.contentResolver
                    .openOutputStream(destination, "wt")
                    ?.bufferedWriter(Charsets.UTF_8)
                    ?: throw IOException("Unable to open CSV destination")

            writer.use { output ->
                output.append('\uFEFF')
                records.forEach { record ->
                    record.forEachIndexed { index, value ->
                        if (index > 0) output.append(',')
                        output.writeCsvField(value)
                    }
                    output.append("\r\n")
                }
            }
        }

        private fun Writer.writeCsvField(value: String) {
            val safeValue = value.escapeSpreadsheetFormula()
            append('"')
            safeValue.forEach { character ->
                if (character == '"') append('"')
                append(character)
            }
            append('"')
        }

        private fun String.escapeSpreadsheetFormula(): String {
            val firstMeaningfulCharacter = firstOrNull { character -> !character.isWhitespace() }
            return if (firstMeaningfulCharacter != null && firstMeaningfulCharacter in CSV_FORMULA_PREFIXES) {
                "'$this"
            } else {
                this
            }
        }

        private companion object {
            val CSV_FORMULA_PREFIXES = setOf('=', '+', '-', '@')
        }
    }
