package android.media.audiofx

open class AudioEffect {
    companion object {
        const val ACTION_DISPLAY_AUDIO_EFFECT_CONTROL_PANEL = "android.media.action.DISPLAY_AUDIO_EFFECT_CONTROL_PANEL"
        const val EXTRA_AUDIO_SESSION = "android.media.extra.AUDIO_SESSION"
        const val EXTRA_PACKAGE_NAME = "android.media.extra.PACKAGE_NAME"
        const val EXTRA_CONTENT_TYPE = "android.media.extra.CONTENT_TYPE"
        const val CONTENT_TYPE_MUSIC = 0
    }
}
