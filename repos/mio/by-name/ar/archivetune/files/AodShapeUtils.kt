package moe.rukamori.archivetune.ui.utils
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.dp
import moe.rukamori.archivetune.constants.AodThumbnailShape

fun AodThumbnailShape.supportsArtworkGlowShadow(): Boolean = false

@Composable
fun AodThumbnailShape.toComposeShape(cornerRadius: Float, startAngle: Int): Shape =
    remember(cornerRadius) { RoundedCornerShape(cornerRadius.coerceIn(0f, 128f).dp) }
