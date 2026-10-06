package androidx.core.graphics

import android.graphics.Color

// android.graphics.Color is an int; androidx.core.graphics.toColorInt converts a
// compose/androidx Color back to it. The port only needs the compile surface.
inline fun androidx.compose.ui.graphics.Color.toColorInt(): Int = Color.argb(
    (alpha * 255.0f + 0.5f).toInt(),
    (red * 255.0f + 0.5f).toInt(),
    (green * 255.0f + 0.5f).toInt(),
    (blue * 255.0f + 0.5f).toInt(),
)

object ColorUtils {
    fun setAlphaComponent(color: Int, alpha: Int): Int = color

    fun compositeColors(foreground: Int, background: Int): Int = foreground

    fun calculateLuminance(color: Int): Double = 0.0

    fun calculateContrast(foreground: Int, background: Int): Double = 1.0

    fun blendARGB(color1: Int, color2: Int, ratio: Float): Int = color1

    fun RGBToHSL(r: Int, g: Int, b: Int, outHsl: FloatArray) {}
}
