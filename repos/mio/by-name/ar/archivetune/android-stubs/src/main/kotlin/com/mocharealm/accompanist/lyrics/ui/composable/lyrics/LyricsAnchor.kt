package com.mocharealm.accompanist.lyrics.ui.composable.lyrics

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/* Where the karaoke view anchors its focused line, in viewport pixels/DP from the top. */
sealed class LyricsAnchor {
    abstract val offset: Dp

    data class Fixed(override val offset: Dp = 0.dp) : LyricsAnchor()
}
