package androidx.room

import android.content.Context

object Room {
    fun <T : RoomDatabase> databaseBuilder(
        context: Context,
        klass: Class<T>,
        name: String,
    ): RoomDatabase.Builder<T> = RoomDatabase.Builder()

    fun <T : RoomDatabase> inMemoryDatabaseBuilder(
        context: Context,
        klass: Class<T>,
    ): RoomDatabase.Builder<T> = RoomDatabase.Builder()
}
