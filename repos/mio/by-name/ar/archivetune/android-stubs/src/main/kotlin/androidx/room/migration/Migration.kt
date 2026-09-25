package androidx.room.migration
import androidx.sqlite.db.SupportSQLiteDatabase

abstract class Migration(val startVersion: Int, val endVersion: Int) {
    abstract fun migrate(db: SupportSQLiteDatabase)
}
