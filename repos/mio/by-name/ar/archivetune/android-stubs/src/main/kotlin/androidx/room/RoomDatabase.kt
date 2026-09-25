package androidx.room
import androidx.sqlite.db.SupportSQLiteDatabase
import java.util.concurrent.Executor

open class RoomDatabase : java.io.Closeable {
    val queryExecutor: Executor = TODO()
    val transactionExecutor: Executor = TODO()
    
    fun runInTransaction(body: Runnable) {}
    override fun close() {}

    enum class JournalMode {
        AUTOMATIC, TRUNCATE, WRITE_AHEAD_LOGGING
    }

    open class Builder<T : RoomDatabase> {
        fun build(): T = TODO()
        fun setJournalMode(mode: JournalMode): Builder<T> = this
        fun addMigrations(vararg migrations: androidx.room.migration.Migration): Builder<T> = this
        fun addCallback(callback: Callback): Builder<T> = this
        fun fallbackToDestructiveMigration(): Builder<T> = this
        fun addAutoMigrationSpec(spec: androidx.room.migration.AutoMigrationSpec): Builder<T> = this
    }

    open class Callback {
        open fun onCreate(db: SupportSQLiteDatabase) {}
        open fun onOpen(db: SupportSQLiteDatabase) {}
        open fun onDestructiveMigration(db: SupportSQLiteDatabase) {}
    }
}

suspend fun <R> RoomDatabase.withTransaction(block: suspend () -> R): R = block()
