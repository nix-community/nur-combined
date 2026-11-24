package com.materialkolor.ktx

import android.graphics.Color as AndroidColor
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import com.materialkolor.hct.Hct

/*
 * The real MaterialKolor converts to/from HCT. The port has no HCT engine, so the
 * nearest HSV representation is used instead: hue in degrees, chroma as 0..100
 * saturation and tone as 0..100 value. Returning constant zero made every
 * paletteStyleFor() decision "Monochrome" and every toColor() gray.
 */
fun Color.toHct(): Hct {
    val hsv = FloatArray(3)
    AndroidColor.colorToHSV(toArgb(), hsv)
    return Hct(
        hue = hsv[0].toDouble(),
        chroma = hsv[1] * 100.0,
        tone = hsv[2] * 100.0,
    )
}

fun Hct.toColor(): Color =
    Color(
        AndroidColor.HSVToColor(
            floatArrayOf(
                hue.toFloat(),
                (chroma / 100.0).toFloat().coerceIn(0f, 1f),
                (tone / 100.0).toFloat().coerceIn(0f, 1f),
            ),
        ),
    )
