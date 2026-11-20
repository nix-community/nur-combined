package androidx.graphics.shapes

import androidx.compose.ui.graphics.Path

/*
 * androidx.graphics.shapes now ships real RoundedPolygon/Morph classes on the runtime
 * classpath, so none of those types are stubbed here anymore. Only the Android-only
 * toPath() conversion (which would produce an android.graphics.Path) is missing on
 * desktop; upstream turns polygons into paths and reads their bounds.
 */

/** Stand-in for android.graphics.Path; only `asComposePath()` is ever called on it. */
class PlatformPath {
    fun asComposePath(): Path = Path()
}

fun RoundedPolygon.toPath(): PlatformPath = PlatformPath()

fun Morph.toPath(progress: Float = 0f): PlatformPath = PlatformPath()
