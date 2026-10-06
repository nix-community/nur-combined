package androidx.sqlite.db

import android.database.Cursor
import android.content.ContentValues

interface SupportSQLiteDatabase : java.io.Closeable {
    fun beginTransactionNonExclusive()
    fun endTransaction()
    fun setTransactionSuccessful()
    fun query(query: String): Cursor
    fun query(query: String, bindArgs: Array<out Any?>): Cursor
    fun query(query: SupportSQLiteQuery): Cursor
    fun execSQL(sql: String)
    fun execSQL(sql: String, bindArgs: Array<out Any?>)
    fun insert(table: String, conflictAlgorithm: Int, values: ContentValues): Long
    fun update(table: String, conflictAlgorithm: Int, values: ContentValues, whereClause: String?, whereArgs: Array<out Any?>?): Int
    fun delete(table: String, whereClause: String?, whereArgs: Array<out Any?>?): Int
    fun isOpen(): Boolean = true
    fun isReadOnly(): Boolean = false
    val version: Int get() = 0
    val path: String? get() = null
}
