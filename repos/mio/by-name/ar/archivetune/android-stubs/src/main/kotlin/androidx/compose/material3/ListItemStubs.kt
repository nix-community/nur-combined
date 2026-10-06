package androidx.compose.material3

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

// Material3-Expressive additions to the real ListItemDefaults that Compose
// Multiplatform's material3-desktop 1.7.0 does not ship yet. Everything is typed
// loosely on purpose: the desktop port only needs the app to compile.

val ListItemDefaults.SegmentedGap: Dp get() = 0.dp

fun ListItemDefaults.shapes(shape: Shape = androidx.compose.ui.graphics.RectangleShape): Shape =
    androidx.compose.ui.graphics.RectangleShape

fun ListItemDefaults.segmentedShapes(index: Int, count: Int): Shape =
    androidx.compose.ui.graphics.RectangleShape

fun ListItemDefaults.segmentedColors(
    containerColor: Color = Color.Unspecified,
    selectedContainerColor: Color = Color.Unspecified,
): Any = Any()
