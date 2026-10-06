package androidx.media3.datasource

/*
 * media3's HttpDataSource with its nested exception type. Upstream inspects
 * `InvalidResponseCodeException.responseCode` when reporting playback errors.
 */
open class HttpDataSource {
    open class HttpDataSourceException(
        message: String? = null,
        val dataSpec: DataSpec? = null,
        val type: Int = 0,
    ) : Exception(message)

    open class InvalidResponseCodeException(
        val responseCode: Int = 0,
        val responseMessage: String? = null,
        val headerFields: Map<String, List<String>> = emptyMap(),
        dataSpec: DataSpec? = null,
    ) : HttpDataSourceException("Invalid response code $responseCode", dataSpec)

    companion object { }
}
