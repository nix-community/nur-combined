package androidx.media3.datasource

open class DataSpec {
    val length: Long = 0L
    val position: Long = 0L
    val uri: android.net.Uri? = null
    val key: String? = null
    val absoluteStreamPosition: Long = 0L
    open fun subrange(offset: Long, length: Long): DataSpec = this

    open fun subrange(offset: Long): DataSpec = this
    companion object { }
}
