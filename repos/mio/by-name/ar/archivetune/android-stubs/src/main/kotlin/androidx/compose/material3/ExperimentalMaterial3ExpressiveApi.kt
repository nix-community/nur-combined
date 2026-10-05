package androidx.compose.material3

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.drawscope.DrawScope

@RequiresOptIn(message = "This Material3 API is experimental and may change.")
@Retention(AnnotationRetention.BINARY)
@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION, AnnotationTarget.PROPERTY, AnnotationTarget.ANNOTATION_CLASS)
annotation class ExperimentalMaterial3ExpressiveApi

fun Any.toShape(startAngle: Int = 0): Any = Any()

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
