package moe.rukamori.archivetune.ui.player

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
// The Player screen passes its own model, not media3's.
import moe.rukamori.archivetune.models.MediaMetadata

/*
 * Upstream's AOD ("always on display") player is an Android ambient/dream surface:
 * it renders into a DreamService window and drives the AOD tile and clock widget.
 * None of that exists on the JVM desktop. The port keeps the composable's signature
 * so the Player screen still compiles, but it renders nothing, which also lets the
 * AOD clock widget and touch-lock overlay be dropped.
 */
@Composable
fun AodPlayerScreen(
    mediaMetadata: MediaMetadata,
    isPlaying: Boolean,
    position: Long,
    duration: Long,
    sliderPosition: Long?,
    canSkipPrevious: Boolean,
    canSkipNext: Boolean,
    thumbnailCornerRadius: Float,
    onPlayPause: () -> Unit,
    onSkipPrevious: () -> Unit,
    onSkipNext: () -> Unit,
    onSeek: (Long) -> Unit,
    onSeekFinished: () -> Unit,
    onExit: () -> Unit,
    modifier: Modifier = Modifier,
    lyricsText: String? = null,
) {
    // No-op: the desktop port has no ambient/AOD surface.
}
