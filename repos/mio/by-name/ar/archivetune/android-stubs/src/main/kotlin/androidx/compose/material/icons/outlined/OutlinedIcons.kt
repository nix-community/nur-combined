package androidx.compose.material.icons.outlined

import androidx.compose.material.icons.Icons
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.Dp

/*
 * These live in material-icons-extended, which is not on the port's classpath; upstream imports
 * them as top-level symbols from this package.
 */
private fun outlinedIcon(name: String): ImageVector =
    ImageVector
        .Builder(
            name = name,
            defaultWidth = Dp(24f),
            defaultHeight = Dp(24f),
            viewportWidth = 24f,
            viewportHeight = 24f,
        ).build()

val Icons.Outlined.Album: ImageVector get() = outlinedIcon("Album")

val Icons.Outlined.LibraryMusic: ImageVector get() = outlinedIcon("LibraryMusic")

val Icons.Outlined.MusicNote: ImageVector get() = outlinedIcon("MusicNote")

val Icons.Outlined.QueueMusic: ImageVector get() = outlinedIcon("QueueMusic")
