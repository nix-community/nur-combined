package androidx.graphics.shapes

open class RoundedPolygon {
    /* Upstream converts polygons to paths and reads their bounds (wavy seek bar artwork). */
    fun toPath(): PlatformPath = PlatformPath()

    fun calculateBounds(): FloatArray = FloatArray(4)

    companion object { }
}
