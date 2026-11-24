package com.materialkolor

import androidx.compose.material3.ColorScheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.graphics.luminance

/*
 * Desktop stand-in for MaterialKolor's dynamic schemes.
 *
 * The real library derives a full tonal palette from the seed colour through HCT.
 * The port has no HCT engine, so it starts from Material3's baseline light/dark
 * scheme and tints the primary roles with the seed. What matters here is that the
 * result follows `isDark`: returning `darkColorScheme()` from every entry point
 * made light mode render a dark palette as soon as a custom theme colour was used.
 */
private fun seededScheme(
    seedColor: Color,
    isDark: Boolean,
    isAmoled: Boolean,
): ColorScheme {
    val base = if (isDark) darkColorScheme() else lightColorScheme()
    val scheme =
        base.copy(
            primary = seedColor,
            onPrimary = if (seedColor.luminance() > 0.5f) Color.Black else Color.White,
            primaryContainer =
                if (isDark) {
                    lerp(Color.Black, seedColor, 0.45f)
                } else {
                    lerp(Color.White, seedColor, 0.30f)
                },
            onPrimaryContainer = if (isDark) Color.White else Color.Black,
            surfaceTint = seedColor,
        )
    return if (isDark && isAmoled) {
        scheme.copy(background = Color.Black, surface = Color.Black)
    } else {
        scheme
    }
}

fun dynamicColorScheme(
    seedColor: Color,
    isDark: Boolean,
    isAmoled: Boolean = false,
    contrastLevel: Double = 0.0,
    style: PaletteStyle = PaletteStyle.TonalSpot,
): ColorScheme = seededScheme(seedColor, isDark, isAmoled)

fun dynamicLightColorScheme(
    seedColor: Color,
    isAmoled: Boolean = false,
    contrastLevel: Double = 0.0,
    style: PaletteStyle = PaletteStyle.TonalSpot,
): ColorScheme = seededScheme(seedColor, isDark = false, isAmoled = isAmoled)

fun dynamicDarkColorScheme(
    seedColor: Color,
    isAmoled: Boolean = false,
    contrastLevel: Double = 0.0,
    style: PaletteStyle = PaletteStyle.TonalSpot,
): ColorScheme = seededScheme(seedColor, isDark = true, isAmoled = isAmoled)
