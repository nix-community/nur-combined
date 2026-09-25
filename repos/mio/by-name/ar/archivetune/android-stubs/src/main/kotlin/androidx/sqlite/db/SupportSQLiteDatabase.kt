package androidx.sqlite.db

interface SupportSQLiteDatabase {
    fun beginTransactionNonExclusive()
    fun endTransaction()
    fun setTransactionSuccessful()
}
