package androidx.compose.material3

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.drawscope.DrawScope

@RequiresOptIn(message = "This Material3 API is experimental and may change.")
@Retention(AnnotationRetention.BINARY)
@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION, AnnotationTarget.PROPERTY, AnnotationTarget.ANNOTATION_CLASS)
annotation class ExperimentalMaterial3ExpressiveApi

fun Any.toShape(startAngle: Int = 0): androidx.compose.ui.graphics.Shape =
    androidx.compose.ui.graphics.RectangleShape

@Composable
fun LinearWavyProgressIndicator(
    progress: () -> Float,
    modifier: androidx.compose.ui.Modifier = androidx.compose.ui.Modifier,
    color: androidx.compose.ui.graphics.Color = androidx.compose.ui.graphics.Color.Unspecified,
    trackColor: androidx.compose.ui.graphics.Color = androidx.compose.ui.graphics.Color.Unspecified,
    strokeCap: androidx.compose.ui.graphics.StrokeCap = androidx.compose.ui.graphics.StrokeCap.Round,
    gapSize: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp.Unspecified,
    drawStopIndicator: (DrawScope.() -> Unit)? = null
) {}

@Composable
fun LinearWavyProgressIndicator(
    modifier: androidx.compose.ui.Modifier = androidx.compose.ui.Modifier,
    color: androidx.compose.ui.graphics.Color = androidx.compose.ui.graphics.Color.Unspecified,
    trackColor: androidx.compose.ui.graphics.Color = androidx.compose.ui.graphics.Color.Unspecified,
    strokeCap: androidx.compose.ui.graphics.StrokeCap = androidx.compose.ui.graphics.StrokeCap.Round,
    gapSize: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp.Unspecified
) {}

/*
 * Upstream passes explicit Stroke objects plus an amplitude lambda. These three parameters
 * are deliberately without defaults: that keeps calls using them applicable only to this
 * overload, so the two above stay unambiguous.
 */
@Composable
fun LinearWavyProgressIndicator(
    progress: () -> Float,
    amplitude: (Float) -> Float,
    modifier: androidx.compose.ui.Modifier = androidx.compose.ui.Modifier,
    color: androidx.compose.ui.graphics.Color = androidx.compose.ui.graphics.Color.Unspecified,
    trackColor: androidx.compose.ui.graphics.Color = androidx.compose.ui.graphics.Color.Unspecified,
    strokeCap: androidx.compose.ui.graphics.StrokeCap = androidx.compose.ui.graphics.StrokeCap.Round,
    gapSize: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp.Unspecified,
    stopSize: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp.Unspecified,
    wavelength: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp.Unspecified,
    waveSpeed: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp.Unspecified,
    drawStopIndicator: (androidx.compose.ui.graphics.drawscope.DrawScope.() -> Unit)? = null,
) {}

@Composable
fun LinearWavyProgressIndicator(
    progress: () -> Float,
    stroke: androidx.compose.ui.graphics.drawscope.Stroke,
    trackStroke: androidx.compose.ui.graphics.drawscope.Stroke,
    amplitude: (Float) -> Float,
    modifier: androidx.compose.ui.Modifier = androidx.compose.ui.Modifier,
    color: androidx.compose.ui.graphics.Color = androidx.compose.ui.graphics.Color.Unspecified,
    trackColor: androidx.compose.ui.graphics.Color = androidx.compose.ui.graphics.Color.Unspecified,
    stopSize: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp.Unspecified,
    gapSize: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp.Unspecified,
    wavelength: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp.Unspecified,
    waveSpeed: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp.Unspecified,
    drawStopIndicator: (androidx.compose.ui.graphics.drawscope.DrawScope.() -> Unit)? = null,
) {}

@Composable
fun CircularWavyProgressIndicator(
    progress: () -> Float,
    modifier: androidx.compose.ui.Modifier = androidx.compose.ui.Modifier,
    color: androidx.compose.ui.graphics.Color = androidx.compose.ui.graphics.Color.Unspecified,
    trackColor: androidx.compose.ui.graphics.Color = androidx.compose.ui.graphics.Color.Unspecified,
    strokeCap: androidx.compose.ui.graphics.StrokeCap = androidx.compose.ui.graphics.StrokeCap.Round,
    gapSize: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp.Unspecified
) {}

@Composable
fun CircularWavyProgressIndicator(
    modifier: androidx.compose.ui.Modifier = androidx.compose.ui.Modifier,
    color: androidx.compose.ui.graphics.Color = androidx.compose.ui.graphics.Color.Unspecified,
    trackColor: androidx.compose.ui.graphics.Color = androidx.compose.ui.graphics.Color.Unspecified,
    strokeCap: androidx.compose.ui.graphics.StrokeCap = androidx.compose.ui.graphics.StrokeCap.Round,
    gapSize: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp.Unspecified
) {}
