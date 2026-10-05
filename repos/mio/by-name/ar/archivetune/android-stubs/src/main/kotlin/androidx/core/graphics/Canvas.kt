package androidx.core.graphics

import android.graphics.Canvas

inline fun Canvas.withTranslation(x: Float = 0f, y: Float = 0f, block: Canvas.() -> Unit) {
    val checkpoint = save()
    translate(x, y)
    try {
        block()
    } finally {
        restoreToCount(checkpoint)
    }
}

inline fun Canvas.withClip(clipPath: android.graphics.Path, block: Canvas.() -> Unit) {
    val checkpoint = save()
    try {
        block()
    } finally {
        restoreToCount(checkpoint)
    }
}
