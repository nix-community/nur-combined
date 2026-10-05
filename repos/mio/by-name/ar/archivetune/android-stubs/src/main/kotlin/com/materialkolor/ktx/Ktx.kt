package com.materialkolor.ktx

import androidx.compose.ui.graphics.Color
import com.materialkolor.hct.Hct

fun Color.toHct(): Hct = Hct.from(0.0, 0.0, 0.0)
fun Hct.toColor(): Color = Color.Gray
