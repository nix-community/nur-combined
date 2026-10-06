package androidx.media3.datasource.cache

/*
 * media3's ContentMetadata. Upstream reads values out of it via
 * getContentMetadata(key).get(ContentMetadata.KEY_CONTENT_LENGTH, -1L).
 */
open class ContentMetadata {
    fun get(key: String, defaultValue: Long): Long = defaultValue

    fun get(key: String, defaultValue: String?): String? = defaultValue

    fun get(key: String, defaultValue: ByteArray?): ByteArray? = defaultValue

    fun contains(key: String): Boolean = false

    companion object {
        const val KEY_CONTENT_LENGTH: String = "exo_len"

        @JvmStatic
        fun getContentMetadataKey(key: String): String? = null
    }
}
