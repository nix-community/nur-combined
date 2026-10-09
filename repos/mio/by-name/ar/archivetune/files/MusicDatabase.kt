package moe.rukamori.archivetune.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import androidx.room.immediateTransaction
import androidx.room.useWriterConnection
import androidx.sqlite.driver.bundled.BundledSQLiteDriver
import moe.rukamori.archivetune.db.entities.*
import java.io.File
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import kotlin.coroutines.resume
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withTimeout

@Database(
    entities = [
        SongEntity::class,
        ArtistEntity::class,
        AlbumEntity::class,
        PlaylistEntity::class,
        PodcastEntity::class,
        SongArtistMap::class,
        SongAlbumMap::class,
        AlbumArtistMap::class,
        PlaylistSongMap::class,
        SearchHistory::class,
        FormatEntity::class,
        LyricsEntity::class,
        LocalMusicAlias::class,
        Event::class,
        RelatedSongMap::class,
        SetVideoIdEntity::class,
        PlayCountEntity::class,
        TagEntity::class,
        PlaylistTagMap::class,
        LibraryTopMixEntity::class,
        LibraryTopMixSongMap::class,
    ],
    views = [
        LibrarySongArtistMap::class,
        SortedSongArtistMap::class,
        SortedSongAlbumMap::class,
        PlaylistSongMapPreview::class,
    ],
    version = 37,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class InternalDatabase : RoomDatabase() {
    abstract val dao: DatabaseDao

    companion object {
        const val DB_NAME = "song.db"

        fun newInstance(context: Context): MusicDatabase {
            val dbFile = File(System.getProperty("user.dir"), ".archivetune.db")
            // Room's KMP runtime keeps blocking DAO functions working on the JVM through the
            // androidx.room.util shims in RoomJvmSupport.kt, which need a query coroutine context.
            val db = Room.databaseBuilder<InternalDatabase>(
                name = dbFile.absolutePath,
                factory = { InternalDatabase_Impl() },
            )
                .setDriver(BundledSQLiteDriver())
                .setQueryCoroutineContext(Dispatchers.IO)
                .fallbackToDestructiveMigration(dropAllTables = true)
                .fallbackToDestructiveMigrationOnDowngrade(dropAllTables = true)
                .build()
            return MusicDatabase(db)
        }
    }
}

class MusicDatabase(
    private val delegate: InternalDatabase,
) : DatabaseDao by delegate.dao {

    private val queryExecutor = Executors.newSingleThreadExecutor()
    private val transactionExecutor = Executors.newSingleThreadExecutor()

    fun query(block: MusicDatabase.() -> Unit) =
        queryExecutor.execute {
            block(this@MusicDatabase)
        }

    fun transaction(block: MusicDatabase.() -> Unit) =
        transactionExecutor.execute {
            block(this@MusicDatabase)
        }

    suspend fun awaitIdle(timeoutMs: Long = 5_000L) {
        withTimeout(timeoutMs) {
            awaitExecutor(queryExecutor)
            awaitExecutor(transactionExecutor)
        }
    }

    suspend fun <R> withTransaction(block: suspend MusicDatabase.() -> R): R =
        delegate.useWriterConnection { transactor ->
            transactor.immediateTransaction {
                block(this@MusicDatabase)
            }
        }

    fun close() = delegate.close()

    private suspend fun awaitExecutor(executor: Executor) {
        suspendCancellableCoroutine { cont ->
            executor.execute {
                if (cont.isActive) cont.resume(Unit)
            }
        }
    }
}
