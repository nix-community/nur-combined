package androidx.room

/*
 * The app (and Room itself) treat these as androidx.sqlite.db types. The port's earlier stub
 * declared *separate* classes in this package, which made every database callback argument and
 * every RoomDatabase.openHelper read a "type mismatch: androidx.room.X, but androidx.sqlite.db.X
 * was expected".
 */
typealias SupportSQLiteDatabase = androidx.sqlite.db.SupportSQLiteDatabase

typealias SupportSQLiteOpenHelper = androidx.sqlite.db.SupportSQLiteOpenHelper

val RoomDatabase.openHelper: SupportSQLiteOpenHelper
    get() = TODO()
