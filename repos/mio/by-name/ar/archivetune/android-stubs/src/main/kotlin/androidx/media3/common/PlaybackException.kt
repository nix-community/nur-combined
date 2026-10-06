package androidx.media3.common

open class PlaybackException(
    message: String?,
    cause: Throwable?,
    val errorCode: Int = ERROR_CODE_UNSPECIFIED,
) : Exception(message, cause) {
    val errorCodeName: String = ""

    companion object {
        const val ERROR_CODE_UNSPECIFIED = 1000
        const val ERROR_CODE_REMOTE_ERROR = 1001
        const val ERROR_CODE_BEHIND_LIVE_WINDOW = 1002
        const val ERROR_CODE_TIMEOUT = 1003
        const val ERROR_CODE_FAILED_RUNTIME_CHECK = 1004
        const val ERROR_CODE_IO_UNSPECIFIED = 2000
        const val ERROR_CODE_IO_NETWORK_CONNECTION_FAILED = 2001
        const val ERROR_CODE_IO_NETWORK_CONNECTION_TIMEOUT = 2002
        const val ERROR_CODE_IO_INVALID_HTTP_CONTENT_TYPE = 2003
        const val ERROR_CODE_IO_BAD_HTTP_STATUS = 2004
        const val ERROR_CODE_IO_FILE_NOT_FOUND = 2005
        const val ERROR_CODE_IO_NO_PERMISSION = 2006
        const val ERROR_CODE_IO_CLEARTEXT_NOT_PERMITTED = 2007
        const val ERROR_CODE_IO_READ_POSITION_OUT_OF_RANGE = 2008
        const val ERROR_CODE_PARSING_CONTAINER_MALFORMED = 3001
        const val ERROR_CODE_PARSING_MANIFEST_MALFORMED = 3002
        const val ERROR_CODE_PARSING_CONTAINER_UNSUPPORTED = 3003
        const val ERROR_CODE_PARSING_MANIFEST_UNSUPPORTED = 3004
        const val ERROR_CODE_DECODER_INIT_FAILED = 4001
        const val ERROR_CODE_DECODER_QUERY_FAILED = 4002
        const val ERROR_CODE_DECODING_FAILED = 4003
        const val ERROR_CODE_DECODING_FORMAT_EXCEEDS_CAPABILITIES = 4004
        const val ERROR_CODE_DECODING_FORMAT_UNSUPPORTED = 4005
        const val ERROR_CODE_AUDIO_TRACK_INIT_FAILED = 5001
        const val ERROR_CODE_AUDIO_TRACK_WRITE_FAILED = 5002
        const val ERROR_CODE_UNSUPPORTED_OPERATION = 6001
    }
}
