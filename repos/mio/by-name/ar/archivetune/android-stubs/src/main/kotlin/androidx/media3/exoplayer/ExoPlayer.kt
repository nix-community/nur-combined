package androidx.media3.exoplayer

import android.content.Context
import androidx.media3.common.Player

abstract class ExoPlayer : Player {
    class Builder(context: Context) {
        fun setMediaSourceFactory(factory: Any): Builder = this
        fun setRenderersFactory(factory: Any): Builder = this
        fun setLoadControl(control: Any): Builder = this
        fun setTrackSelector(selector: Any): Builder = this
        fun setHandleAudioBecomingNoisy(handle: Boolean): Builder = this
        fun setWakeMode(mode: Int): Builder = this
        fun setAudioAttributes(attrs: Any, handleAudioFocus: Boolean): Builder = this
        fun build(): ExoPlayer = ExoPlayer()
    }
}
