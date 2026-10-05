package androidx.room

class SupportSQLiteDatabase

class SupportSQLiteOpenHelper {
    val writableDatabase: SupportSQLiteDatabase = SupportSQLiteDatabase()
}

val RoomDatabase.openHelper: SupportSQLiteOpenHelper
    get() = SupportSQLiteOpenHelper()
