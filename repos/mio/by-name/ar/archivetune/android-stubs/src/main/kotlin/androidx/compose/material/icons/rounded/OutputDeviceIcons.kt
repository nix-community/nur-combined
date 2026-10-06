package androidx.compose.material.icons.rounded

import androidx.compose.material.icons.Icons
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.Dp

/*
 * These live in material-icons-extended, which is not on the port's classpath; upstream imports
 * them as top-level symbols from this package.
 */
private fun outputDeviceIcon(name: String): ImageVector =
    ImageVector
        .Builder(
            name = name,
            defaultWidth = Dp(24f),
            defaultHeight = Dp(24f),
            viewportWidth = 24f,
            viewportHeight = 24f,
        ).build()

val Icons.Rounded.Bluetooth: ImageVector get() = outputDeviceIcon("Bluetooth")

val Icons.Rounded.Cable: ImageVector get() = outputDeviceIcon("Cable")

val Icons.Rounded.Headphones: ImageVector get() = outputDeviceIcon("Headphones")

val Icons.Rounded.Speaker: ImageVector get() = outputDeviceIcon("Speaker")

val Icons.Rounded.Usb: ImageVector get() = outputDeviceIcon("Usb")

val Icons.Rounded.SpeakerGroup: ImageVector get() = outputDeviceIcon("SpeakerGroup")

val Icons.Rounded.PhoneAndroid: ImageVector get() = outputDeviceIcon("PhoneAndroid")

val Icons.Rounded.Tv: ImageVector get() = outputDeviceIcon("Tv")
