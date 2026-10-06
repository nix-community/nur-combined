package androidx.graphics.shapes

import androidx.compose.ui.graphics.Path

/*
 * androidx.graphics:graphics-shapes is an Android-only artifact, so the port declares the
 * surface upstream uses: `Morph(vararg curves)`, `morph.toPath(progress)`, and the
 * resulting `asComposePath()`.
 */
open class Morph(vararg curves: Any) {
    /* Upstream indexes [0]..[3] (left, top, right, bottom); a member so no import is needed. */
    fun calculateBounds(): FloatArray = FloatArray(4)

    companion object { }
}

/** Stand-in for android.graphics.Path; only `asComposePath()` is ever called on it. */
class PlatformPath {
    fun asComposePath(): Path = Path()
}

fun Morph.toPath(progress: Float = 0f): PlatformPath = PlatformPath()

/* Upstream reads `morph.calculateBounds()` and indexes [0]..[3] (left, top, right, bottom). */
fun Morph.calculateBounds(): FloatArray = FloatArray(4)
