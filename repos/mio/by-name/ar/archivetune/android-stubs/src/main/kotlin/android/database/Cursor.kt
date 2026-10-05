package android.database

open class Cursor : java.io.Closeable {
    open fun moveToFirst(): Boolean = false
    open fun moveToNext(): Boolean = false
    open fun getColumnIndex(columnName: String): Int = 0
    open fun getColumnIndexOrThrow(columnName: String): Int = 0
    override fun close() {}
    
    open fun getString(columnIndex: Int): String? = null
    open fun getInt(columnIndex: Int): Int = 0
    open fun getLong(columnIndex: Int): Long = 0L
    open fun getDouble(columnIndex: Int): Double = 0.0
    open fun getFloat(columnIndex: Int): Float = 0.0f
    open fun getBlob(columnIndex: Int): ByteArray? = null
    open fun isNull(columnIndex: Int): Boolean = false
}
