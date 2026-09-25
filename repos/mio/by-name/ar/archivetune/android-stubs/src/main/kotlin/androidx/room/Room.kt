package androidx.room
import android.content.Context

open class Room {
    companion object {
        fun <T : RoomDatabase> databaseBuilder(context: Context, klass: Class<T>, name: String): RoomDatabase.Builder<T> = RoomDatabase.Builder()
    }
}
