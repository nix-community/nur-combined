package android.database
fun Cursor.getColumnIndexOrThrow(columnName: String): Int = this.getColumnIndex(columnName)
