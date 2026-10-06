package coil3.request

/* Coil's cache policy; upstream reads `networkCachePolicy.readEnabled` in an interceptor. */
class CachePolicy(
    val readEnabled: Boolean = true,
    val writeEnabled: Boolean = true,
) {
    companion object {
        val ENABLED = CachePolicy()
        val DISABLED = CachePolicy(readEnabled = false, writeEnabled = false)
        val READ_ONLY = CachePolicy(writeEnabled = false)
        val WRITE_ONLY = CachePolicy(readEnabled = false)
    }
}
