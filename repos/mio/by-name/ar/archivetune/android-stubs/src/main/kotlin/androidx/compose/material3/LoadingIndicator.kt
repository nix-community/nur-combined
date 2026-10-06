package androidx.compose.material3

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.graphics.shapes.RoundedPolygon

/*
 * Upstream calls LoadingIndicator(modifier, color, polygons) - the polygon list is what the
 * ports earlier one-parameter stub was missing, so every call site failed on parameter names.
 */

@Composable
fun LoadingIndicator(
    modifier: Modifier = Modifier,
    color: Color = Color.Unspecified,
    polygons: List<RoundedPolygon> = emptyList(),
) {}


@Composable
fun LoadingIndicator(
    progress: () -> Float,
    modifier: Modifier = Modifier,
    color: Color = Color.Unspecified,
    polygons: List<RoundedPolygon> = emptyList(),
) {}

/**
 * Real MaterialShapes entries are RoundedPolygons; typed as such so `.toShape()` resolves to a
 * real [Shape] instead of Any (which upstream then refuses to pass where a Shape is expected).
 */
object MaterialShapes {
    val Cookie4Sided: RoundedPolygon get() = RoundedPolygon()
    val Cookie6Sided: RoundedPolygon get() = RoundedPolygon()
    val Cookie7Sided: RoundedPolygon get() = RoundedPolygon()
    val Cookie9Sided: RoundedPolygon get() = RoundedPolygon()
    val Cookie12Sided: RoundedPolygon get() = RoundedPolygon()
    val Sunny: RoundedPolygon get() = RoundedPolygon()
    val Flower: RoundedPolygon get() = RoundedPolygon()
    val Puffy: RoundedPolygon get() = RoundedPolygon()
    val PuffyDiamond: RoundedPolygon get() = RoundedPolygon()
    val Pentagon: RoundedPolygon get() = RoundedPolygon()
    val Gem: RoundedPolygon get() = RoundedPolygon()
    val Diamond: RoundedPolygon get() = RoundedPolygon()
    val Scallop: RoundedPolygon get() = RoundedPolygon()
    val Clover4Leaf: RoundedPolygon get() = RoundedPolygon()
    val Clover8Leaf: RoundedPolygon get() = RoundedPolygon()
    val Burst: RoundedPolygon get() = RoundedPolygon()
    val SoftBurst: RoundedPolygon get() = RoundedPolygon()
    val Boom: RoundedPolygon get() = RoundedPolygon()
    val SoftBoom: RoundedPolygon get() = RoundedPolygon()
    val Circle: RoundedPolygon get() = RoundedPolygon()
    val Square: RoundedPolygon get() = RoundedPolygon()
    val Pill: RoundedPolygon get() = RoundedPolygon()
    val VerySunny: RoundedPolygon get() = RoundedPolygon()
    val Ghostish: RoundedPolygon get() = RoundedPolygon()
    val PixelCircle: RoundedPolygon get() = RoundedPolygon()
    val PixelTriangle: RoundedPolygon get() = RoundedPolygon()
    val Arch: RoundedPolygon get() = RoundedPolygon()
    val Fan: RoundedPolygon get() = RoundedPolygon()
    val Arrow: RoundedPolygon get() = RoundedPolygon()
    val Slanted: RoundedPolygon get() = RoundedPolygon()
}
