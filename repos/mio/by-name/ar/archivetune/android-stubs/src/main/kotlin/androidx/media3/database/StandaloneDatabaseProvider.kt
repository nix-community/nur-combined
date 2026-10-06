package androidx.media3.database

/*
 * Upstream builds it as StandaloneDatabaseProvider(context) and passes it where a DatabaseProvider
 * is expected, so it implements that interface.
 */
open class StandaloneDatabaseProvider(
    val context: Any? = null,
) : DatabaseProvider {
    override fun getWritableDatabase(): Any? = null

    override fun getReadableDatabase(): Any? = null

    companion object { }
}
