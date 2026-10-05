package androidx.compose.material3

import androidx.compose.ui.unit.dp
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.Dp

val ListItemDefaults.SegmentedGap: Dp get() = 0.dp
val MaterialTheme.motionScheme: Any get() = Any()
fun ListItemDefaults.shapes(shape: Shape = androidx.compose.ui.graphics.RectangleShape): Any = Any()
fun ListItemDefaults.segmentedShapes(index: Int, count: Int): Any = Any()
fun ListItemDefaults.segmentedColors(containerColor: Color, selectedContainerColor: Color): Any = Any()
object ListItemDefaults
object MaterialTheme
