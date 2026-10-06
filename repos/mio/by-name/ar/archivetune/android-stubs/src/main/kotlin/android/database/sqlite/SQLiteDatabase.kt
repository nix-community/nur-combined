package android.database.sqlite

open class SQLiteDatabase {
    interface CursorFactory

    companion object {
        const val CONFLICT_ROLLBACK = 1
        const val CONFLICT_ABORT = 2
        const val CONFLICT_FAIL = 3
        const val CONFLICT_IGNORE = 4
        const val CONFLICT_REPLACE = 5
        const val CONFLICT_NONE = 0
    }
}

interface DatabaseErrorHandler
