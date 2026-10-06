package androidx.media3.common

object C {
    const val TIME_UNSET: Long = Long.MIN_VALUE + 1
    const val INDEX_UNSET: Int = -1
    const val POSITION_UNSET: Int = -1
    const val LENGTH_UNSET: Int = -1
    const val RATE_UNSET: Float = -Float.MAX_VALUE
    const val RATE_UNSET_INT: Int = Integer.MIN_VALUE
    const val DEFAULT_SEEK_BACK_INCREMENT_MS: Long = 5000
    const val DEFAULT_SEEK_FORWARD_INCREMENT_MS: Long = 15000
    const val DEFAULT_MAX_SEEK_TO_PREVIOUS_POSITION_MS: Long = 3000
    const val AUDIO_SESSION_ID_UNSET: Int = 0
    const val CRYPTO_MODE_UNENCRYPTED: Int = 0
    const val TRACK_TYPE_UNKNOWN: Int = -1
    const val TRACK_TYPE_AUDIO: Int = 1
    const val TRACK_TYPE_VIDEO: Int = 2
    const val TRACK_TYPE_TEXT: Int = 3
    const val TRACK_TYPE_IMAGE: Int = 4
    const val TRACK_TYPE_METADATA: Int = 5
    const val TRACK_TYPE_CAMERA_MOTION: Int = 6
    const val TRACK_TYPE_NONE: Int = 7
    const val SELECTION_FLAG_DEFAULT: Int = 1
    const val SELECTION_FLAG_FORCED: Int = 2
    const val PERCENTAGE_UNSET: Int = -1
    const val USAGE_MEDIA: Int = 1
    const val USAGE_UNKNOWN: Int = 0
    const val CONTENT_TYPE_MOVIE: Int = 2
    const val CONTENT_TYPE_MUSIC: Int = 3
    const val MICROS_PER_SECOND: Long = 1000000L
    const val MILLIS_PER_SECOND: Long = 1000L
    const val RESULT_END_OF_INPUT: Int = -1
    const val RESULT_MAX_LENGTH_EXCEEDED: Int = -2
}
