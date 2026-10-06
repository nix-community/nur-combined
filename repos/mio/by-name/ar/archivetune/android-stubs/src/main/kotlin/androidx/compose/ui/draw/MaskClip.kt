package androidx.compose.ui.draw

import androidx.compose.ui.Modifier

/*
 * Modifier.maskClip is a newer compose API than the port's 1.7 line. Upstream calls
 * `.maskClip(MaterialTheme.shapes.extraLarge)` without an import, so fix_theme.py injects this
 * one where used.
 */
fun Modifier.maskClip(shape: Any): Modifier = this

fun Modifier.maskClip(shape: Any, enabled: Boolean): Modifier = this

/* Modifier.maskBorder is a newer compose API too. */
fun Modifier.maskBorder(
    border: androidx.compose.foundation.BorderStroke,
    shape: Any,
    enabled: Boolean = true,
): Modifier = this
