package androidx.compose.material.icons.filled

import androidx.compose.material.icons.Icons
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.Dp

/*
 * These live in material-icons-extended, which is not on the port's classpath; upstream imports
 * them as top-level symbols from this package.
 */
private fun filledIcon(name: String): ImageVector =
    ImageVector
        .Builder(
            name = name,
            defaultWidth = Dp(24f),
            defaultHeight = Dp(24f),
            viewportWidth = 24f,
            viewportHeight = 24f,
        ).build()

val Icons.Filled.CloudDone: ImageVector get() = filledIcon("CloudDone")

val Icons.Filled.CloudOff: ImageVector get() = filledIcon("CloudOff")

val Icons.Filled.CloudQueue: ImageVector get() = filledIcon("CloudQueue")

val Icons.Filled.CloudSync: ImageVector get() = filledIcon("CloudSync")
