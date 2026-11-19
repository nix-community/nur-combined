package android.database.sqlite

open class SQLiteDatabase : java.io.Closeable {
    interface CursorFactory

    open val version: Int = 0

    open fun rawQuery(sql: String?, selectionArgs: Array<String>?): android.database.Cursor =
        android.database.Cursor()

    override fun close() {}

    companion object {
        const val OPEN_READWRITE = 0

        const val NO_LOCALIZED_COLLATORS = 16

        fun openDatabase(path: String, factory: CursorFactory?, flags: Int): SQLiteDatabase =
            SQLiteDatabase()

        const val CONFLICT_ROLLBACK = 1
        const val CONFLICT_ABORT = 2
        const val CONFLICT_FAIL = 3
        const val CONFLICT_IGNORE = 4
        const val CONFLICT_REPLACE = 5
        const val CONFLICT_NONE = 0
    }
}

typealias DatabaseErrorHandler = android.database.DatabaseErrorHandler
