package android.database

import android.database.sqlite.SQLiteDatabase

interface DatabaseErrorHandler {
    fun onCorruption(dbObj: SQLiteDatabase)
}
