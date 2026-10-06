package androidx.media3.database

/*
 * media3's DatabaseProvider is an interface (StandaloneDatabaseProvider implements it), so a
 * class declaration here made StandaloneDatabaseProvider fail to compile.
 */
interface DatabaseProvider {
    fun getWritableDatabase(): Any?

    fun getReadableDatabase(): Any?
}
