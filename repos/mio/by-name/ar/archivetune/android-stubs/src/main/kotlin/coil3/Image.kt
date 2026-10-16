package coil3

import android.graphics.Bitmap
import androidx.compose.ui.graphics.ImageBitmap

open class Image(
    val imageBitmap: ImageBitmap? = null,
    val bitmap: Bitmap? = null,
    val width: Int = bitmap?.width ?: imageBitmap?.width ?: 0,
    val height: Int = bitmap?.height ?: imageBitmap?.height ?: 0,
)

fun Image.toBitmap(): Bitmap = bitmap ?: (if (imageBitmap != null) Bitmap(imageBitmap = imageBitmap) else Bitmap())
