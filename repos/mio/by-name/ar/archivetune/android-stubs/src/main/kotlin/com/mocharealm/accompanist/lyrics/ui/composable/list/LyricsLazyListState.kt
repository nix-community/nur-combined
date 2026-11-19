package com.mocharealm.accompanist.lyrics.ui.composable.list

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember

/*
 * The port of accompanist's lyrics-ui list state. Only the members the app reads are
 * modelled; the karaoke view stub accepts it as an opaque handle.
 */
class LyricsLazyListState {
    val firstVisibleItemIndex: Int = 0
    val firstVisibleItemScrollOffset: Int = 0
    val isScrollInProgress: Boolean = false
}

@Composable
fun rememberLyricsLazyListState(): LyricsLazyListState = remember { LyricsLazyListState() }
