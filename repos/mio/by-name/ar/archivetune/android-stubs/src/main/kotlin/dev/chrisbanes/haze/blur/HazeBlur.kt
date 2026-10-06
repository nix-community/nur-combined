package dev.chrisbanes.haze.blur

import androidx.compose.ui.Modifier
import dev.chrisbanes.haze.HazeInput
import dev.chrisbanes.haze.HazePerformanceMode

// See dev.chrisbanes.haze.Haze.kt: haze-blur is pinned to a newer Compose than the
// port uses, so its builder surface is provided here and does nothing.
class HazeBlurStyle {
    fun blurEnabled(enabled: Boolean) {}

    fun blurRadius(radius: Any) {}

    fun noiseFactor(factor: Float) {}

    fun backgroundColor(color: Any) {}

    fun forceInvalidateOnPreDraw(enabled: Boolean) {}

    fun progressive(progressive: Any) {}

    companion object {
        operator fun invoke(block: HazeBlurStyle.() -> Unit): HazeBlurStyle =
            HazeBlurStyle().apply(block)
    }
}

fun Modifier.hazeBlur(
    input: HazeInput,
    style: HazeBlurStyle = HazeBlurStyle(),
    performanceMode: HazePerformanceMode = HazePerformanceMode.Default,
    expandLayerBounds: Boolean = false,
    blurRadius: Any = Any(),
    backgroundColor: Any = Any(),
    noiseFactor: Float = 0f,
    block: (Any) -> Unit = {},
): Modifier = this
