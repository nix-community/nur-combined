package androidx.media3.datasource

open class DataSpec {
    val length: Long = 0L
    open fun subrange(offset: Long, length: Long): DataSpec = this
    companion object { }
}
