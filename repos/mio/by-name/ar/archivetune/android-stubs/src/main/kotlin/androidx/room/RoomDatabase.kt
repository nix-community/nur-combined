package androidx.room
import androidx.sqlite.db.SupportSQLiteDatabase
import java.util.concurrent.Executor

open class RoomDatabase : java.io.Closeable {
    // Declared as a member (not an extension) so call sites resolve without an import.
    open val openHelper: SupportSQLiteOpenHelper
        get() = TODO()

    val queryExecutor: Executor = Executor { it.run() }
    val transactionExecutor: Executor = Executor { it.run() }
    
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
        fun fallbackToDestructiveMigrationOnDowngrade(): Builder<T> = this
        fun fallbackToDestructiveMigrationFrom(vararg versionNumbers: Int): Builder<T> = this
        fun addAutoMigrationSpec(spec: androidx.room.migration.AutoMigrationSpec): Builder<T> = this
        fun setQueryExecutor(executor: java.util.concurrent.Executor): Builder<T> = this
        fun setTransactionExecutor(executor: java.util.concurrent.Executor): Builder<T> = this
        fun allowMainThreadQueries(): Builder<T> = this
        fun openHelperFactory(factory: Any?): Builder<T> = this
        fun createFromAsset(assetPath: String): Builder<T> = this
        fun createFromFile(file: java.io.File): Builder<T> = this
        fun setAutoCloseTimeout(
            autoCloseTimeout: Long,
            autoCloseTimeoutUnit: java.util.concurrent.TimeUnit,
        ): Builder<T> = this
    }

    open class Callback {
        open fun onCreate(db: SupportSQLiteDatabase) {}
        open fun onOpen(db: SupportSQLiteDatabase) {}
        open fun onDestructiveMigration(db: SupportSQLiteDatabase) {}
    }
}

suspend fun <R> RoomDatabase.withTransaction(block: suspend () -> R): R = block()
