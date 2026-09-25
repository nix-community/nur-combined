package androidx.sqlite.db
import android.database.Cursor
import android.content.ContentValues

interface SupportSQLiteDatabase : java.io.Closeable {
    fun beginTransactionNonExclusive()
    fun endTransaction()
    fun setTransactionSuccessful()
    fun query(query: String): Cursor
    fun query(query: SupportSQLiteQuery): Cursor
    fun execSQL(sql: String)
    fun insert(table: String, conflictAlgorithm: Int, values: ContentValues): Long
}
