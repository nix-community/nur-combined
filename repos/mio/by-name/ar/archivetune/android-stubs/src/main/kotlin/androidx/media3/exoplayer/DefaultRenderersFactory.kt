package androidx.media3.exoplayer

/*
 * Upstream builds renderers as DefaultRenderersFactory(context).setEnableDecoderFallback(true);
 * the earlier stub had no constructor or setters.
 */
open class DefaultRenderersFactory(
    val context: Any? = null,
) {
    open fun setEnableDecoderFallback(enableDecoderFallback: Boolean): DefaultRenderersFactory = this

    open fun setExtensionRendererMode(extensionRendererMode: Int): DefaultRenderersFactory = this

    open fun setEnableAudioTrackPlaybackParams(enable: Boolean): DefaultRenderersFactory = this

    open fun setEnableAudioFloatOutput(enable: Boolean): DefaultRenderersFactory = this

    companion object {
        const val EXTENSION_RENDERER_MODE_OFF = 0
        const val EXTENSION_RENDERER_MODE_PREFER = 1
        const val EXTENSION_RENDERER_MODE_ON = 2
    }
}
