package androidx.media3.datasource

open class DataSpec {
    val length: Long = 0L
    val position: Long = 0L
    val uri: android.net.Uri? = null
    val key: String? = null
    val absoluteStreamPosition: Long = 0L
    val httpRequestHeaders: Map<String, String> = emptyMap()

    open fun subrange(offset: Long, length: Long): DataSpec = this

    open fun subrange(offset: Long): DataSpec = this

    fun buildUpon(): Builder = Builder(this)

    class Builder(origin: DataSpec? = null) {
        private var uri: android.net.Uri? = origin?.uri
        private var headers: Map<String, String> = origin?.httpRequestHeaders ?: emptyMap()

        fun setUri(uri: android.net.Uri): Builder = apply { this.uri = uri }

        fun setUri(uri: String): Builder = apply { this.uri = android.net.Uri.parse(uri) }

        fun setHttpRequestHeaders(headers: Map<String, String>): Builder = apply { this.headers = headers }

        fun build(): DataSpec = DataSpec()
    }

    companion object { }
}
