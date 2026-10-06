package androidx.media3.datasource.cache

/*
 * Upstream constructs SimpleCache(file, evictor, databaseProvider) and treats it as a
 * Cache, so it must extend the Cache fake. Nothing is cached on the desktop port.
 */
open class SimpleCache(
    val file: java.io.File? = null,
    val evictor: Any? = null,
    val databaseProvider: Any? = null,
    val flags: Int = 0,
) : Cache {
    companion object { }
}
