package moe.rukamori.archivetune.ui.player

import android.graphics.Bitmap
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.media3.ui.AspectRatioFrameLayout
import moe.rukamori.archivetune.canvas.CanvasSource

/**
 * Desktop stand-in for the canvas video surface.
 *
 * Upstream drives this with an ExoPlayer plus a PlayerView, both Android media3
 * UI pieces that do not exist on the JVM desktop; the port's ExoPlayer.Builder
 * is a TODO, so the upstream composable crashed as soon as a song exposed a
 * Spotify canvas URL. Canvas video is simply not rendered here and the static
 * artwork underneath stays visible. The signature (names, types and defaults)
 * mirrors upstream so the call sites need no patching.
 */
@Suppress("UNUSED_PARAMETER")
@Composable
internal fun CanvasArtworkPlayer(
    source: CanvasSource?,
    primaryUrl: String?,
    fallbackUrl: String?,
    isPlaying: Boolean,
    modifier: Modifier = Modifier,
    resizeMode: Int = AspectRatioFrameLayout.RESIZE_MODE_FIT,
    onFrameCaptured: ((Bitmap?) -> Unit)? = null,
) {
}
