package moe.rukamori.archivetune.ui.theme

import android.content.Context
import android.graphics.Bitmap
import androidx.compose.ui.graphics.Color

// DefaultThemeColor doesn't exist here, so we just use Color.Gray
fun Bitmap.extractThemeColor(): Color = Color.Gray
fun Bitmap.extractGradientColors(): List<Color> = listOf(Color(0xFF595959), Color(0xFF0D0D0D))
fun extractWallpaperThemeColor(context: Context): Color? = null
