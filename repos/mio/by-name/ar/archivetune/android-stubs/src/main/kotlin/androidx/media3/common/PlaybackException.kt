package androidx.media3.common

open class PlaybackException(message: String?, cause: Throwable?, errorCode: Int) : Exception(message, cause) {
    companion object {
        const val ERROR_CODE_REMOTE_ERROR = 1
    }
}
