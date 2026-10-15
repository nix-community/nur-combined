package androidx.compose.ui.draw

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.border
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Shape

/*
 * Modifier.maskClip is a newer compose API than the port's 1.7 line. Upstream calls
 * `.maskClip(MaterialTheme.shapes.extraLarge)` without an import, so fix_theme.py injects this
 * one where used.
 */
fun Modifier.maskClip(shape: Any): Modifier =
    if (shape is Shape) this.clip(shape) else this

fun Modifier.maskClip(shape: Any, enabled: Boolean): Modifier =
    if (enabled && shape is Shape) this.clip(shape) else this

/* Modifier.maskBorder is a newer compose API too. */
fun Modifier.maskBorder(
    border: BorderStroke,
    shape: Any,
    enabled: Boolean = true,
): Modifier =
    if (enabled && shape is Shape) this.border(border, shape) else this
