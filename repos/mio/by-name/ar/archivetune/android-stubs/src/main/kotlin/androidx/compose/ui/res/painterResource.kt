package androidx.compose.ui.res

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.ColorPainter
import androidx.compose.ui.graphics.painter.Painter

@Composable
fun painterResource(id: Int): Painter = ColorPainter(Color.Transparent)

@Composable
fun painterResource(resourcePath: String): Painter = ColorPainter(Color.Transparent)
