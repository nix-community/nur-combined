package com.materialkolor

import androidx.compose.ui.graphics.Color
import androidx.compose.material3.ColorScheme

fun dynamicColorScheme(
    seedColor: Color,
    isDark: Boolean,
    isAmoled: Boolean = false,
    contrastLevel: Double = 0.0,
    style: PaletteStyle = PaletteStyle.TonalSpot
): ColorScheme = androidx.compose.material3.darkColorScheme()

fun dynamicLightColorScheme(
    seedColor: Color,
    isAmoled: Boolean = false,
    contrastLevel: Double = 0.0,
    style: PaletteStyle = PaletteStyle.TonalSpot
): ColorScheme = androidx.compose.material3.lightColorScheme()

fun dynamicDarkColorScheme(
    seedColor: Color,
    isAmoled: Boolean = false,
    contrastLevel: Double = 0.0,
    style: PaletteStyle = PaletteStyle.TonalSpot
): ColorScheme = androidx.compose.material3.darkColorScheme()
