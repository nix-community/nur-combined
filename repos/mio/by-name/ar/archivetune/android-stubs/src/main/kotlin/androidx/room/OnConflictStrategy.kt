package androidx.room

// Room's on-conflict strategies. The CONFLICT_* aliases mirror SQLite's constants,
// which upstream references directly in a few @Insert/@Update annotations.
object OnConflictStrategy {
    const val REPLACE = 1
    const val ROLLBACK = 2
    const val ABORT = 3
    const val FAIL = 4
    const val IGNORE = 5

    const val CONFLICT_REPLACE = REPLACE
    const val CONFLICT_ROLLBACK = ROLLBACK
    const val CONFLICT_ABORT = ABORT
    const val CONFLICT_FAIL = FAIL
    const val CONFLICT_IGNORE = IGNORE
    const val CONFLICT_NONE = 0
}
