package com.mocharealm.accompanist.lyrics.ui.composable.lyrics

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mocharealm.accompanist.lyrics.core.model.ISyncedLine
import com.mocharealm.accompanist.lyrics.core.model.SyncedLyrics
import com.mocharealm.accompanist.lyrics.core.model.karaoke.KaraokeLine
import com.mocharealm.accompanist.lyrics.core.model.synced.SyncedLine

/*
 * Desktop implementation of KaraokeLyricsView rendering synchronized lyrics.
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
    val realListState = listState as? LazyListState ?: rememberLazyListState()
    val realPos = (currentPosition as? Number)?.toInt() ?: 0
    val realColor = textColor as? Color ?: MaterialTheme.colorScheme.onSurface
    val realStyle = normalLineTextStyle as? TextStyle ?: MaterialTheme.typography.titleMedium

    val lines = lyrics?.lines ?: emptyList()
    val activeIndex = remember(lyrics, realPos) {
        lyrics?.getCurrentFirstHighlightLineIndexByTime(realPos) ?: -1
    }

    LaunchedEffect(activeIndex) {
        if (activeIndex in lines.indices && !realListState.isScrollInProgress) {
            val target = (activeIndex - 2).coerceAtLeast(0)
            realListState.animateScrollToItem(target)
        }
    }

    LazyColumn(
        state = realListState,
        modifier = (modifier as? Modifier ?: Modifier).fillMaxSize(),
        contentPadding = PaddingValues(top = 80.dp, bottom = 180.dp, start = 24.dp, end = 24.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        itemsIndexed(lines) { index, line ->
            val isActive = index == activeIndex
            val alpha = if (isActive) 1f else 0.42f
            val content = when (line) {
                is SyncedLine -> line.content
                is KaraokeLine -> line.syllables.joinToString("") { it.content }
                else -> line.toString()
            }
            val translation = when (line) {
                is SyncedLine -> line.translation
                is KaraokeLine -> line.translation
                else -> null
            }

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onLineClicked(line) }
                    .padding(vertical = 4.dp)
                    .graphicsLayer { this.alpha = alpha }
            ) {
                Text(
                    text = content,
                    style = realStyle.copy(
                        fontSize = if (isActive) (realStyle.fontSize.value + 4).sp else realStyle.fontSize,
                        fontWeight = if (isActive) FontWeight.Bold else FontWeight.Medium,
                    ),
                    color = realColor,
                )
                if (showTranslation && !translation.isNullOrBlank()) {
                    Spacer(Modifier.height(4.dp))
                    Text(
                        text = translation,
                        style = MaterialTheme.typography.bodyMedium,
                        color = realColor.copy(alpha = 0.75f),
                    )
                }
            }
        }
    }
}
