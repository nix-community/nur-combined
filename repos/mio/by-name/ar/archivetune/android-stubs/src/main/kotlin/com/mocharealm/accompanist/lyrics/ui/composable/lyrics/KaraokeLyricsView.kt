package com.mocharealm.accompanist.lyrics.ui.composable.lyrics

import androidx.compose.runtime.Composable
import com.mocharealm.accompanist.lyrics.core.model.ISyncedLine
import com.mocharealm.accompanist.lyrics.core.model.SyncedLyrics

/*
 * com.mocharealm.accompanist:lyrics-ui is published to Maven as sources/javadoc only
 * (no binary jar), so unlike its lyrics-core companion it cannot be used as a real
 * dependency. The port keeps the one composable upstream calls from it; the model
 * types it renders come from the real lyrics-core artifact.
 *
 * The callbacks are typed with lyrics-core's ISyncedLine (not Any) so upstream's
 * `onLineClicked = { line -> line.start / line.selectionKey() }` lambdas infer a receiver
 * that actually has those members.
 */
@Composable
fun KaraokeLyricsView(
    listState: Any,
    lyrics: SyncedLyrics? = null,
    currentPosition: Any = 0L,
    onLineClicked: (ISyncedLine) -> Unit = {},
    onLinePressed: (ISyncedLine) -> Unit = {},
    textColor: Any = Any(),
    normalLineTextStyle: Any = Any(),
    accompanimentLineTextStyle: Any = Any(),
    phoneticTextStyle: Any = Any(),
    blendMode: Any = Any(),
    useBlurEffect: Boolean = false,
    showTranslation: Boolean = false,
    showPhonetic: Boolean = false,
    offset: Any = 0f,
    keepAliveZone: Any = Any(),
    modifier: Any = Any(),
) {
    // No-op: karaoke rendering is not implemented in the desktop port.
}
