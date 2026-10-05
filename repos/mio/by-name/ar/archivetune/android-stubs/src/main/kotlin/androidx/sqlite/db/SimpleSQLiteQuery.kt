package androidx.sqlite.db

class SimpleSQLiteQuery(val query: String, val bindArgs: Array<out Any?> = emptyArray()) : SupportSQLiteQuery()
