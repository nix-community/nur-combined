package androidx.room.migration
import androidx.sqlite.db.SupportSQLiteDatabase

interface AutoMigrationSpec {
    fun onPostMigrate(db: SupportSQLiteDatabase) {}
}
