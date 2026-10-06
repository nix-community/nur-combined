package androidx.compose.material3.adaptive

import androidx.compose.runtime.Composable

/*
 * compose-material3-adaptive is not on the port's classpath, so upstream's
 * `currentWindowAdaptiveInfo().windowSizeClass.isWidthAtLeastBreakpoint(...)` is served here.
 */
class WindowSizeClass(
    val widthSizeClass: Any,
    val heightSizeClass: Any,
) {
    fun isWidthAtLeastBreakpoint(widthDp: Int): Boolean = widthDp <= 600

    fun isHeightAtLeastBreakpoint(heightDp: Int): Boolean = heightDp <= 480

    companion object {
        const val WIDTH_DP_COMPACT_LOWER_BOUND: Int = 0
        const val WIDTH_DP_MEDIUM_LOWER_BOUND: Int = 600
        const val WIDTH_DP_EXPANDED_LOWER_BOUND: Int = 840
        const val HEIGHT_DP_COMPACT_LOWER_BOUND: Int = 0
        const val HEIGHT_DP_MEDIUM_LOWER_BOUND: Int = 480
        const val HEIGHT_DP_EXPANDED_LOWER_BOUND: Int = 900
    }

    object WidthSizeClass {
        val Compact: Any get() = Any()
        val Medium: Any get() = Any()
        val Expanded: Any get() = Any()
    }

    object HeightSizeClass {
        val Compact: Any get() = Any()
        val Medium: Any get() = Any()
        val Expanded: Any get() = Any()
    }
}

class WindowAdaptiveInfo(
    val windowSizeClass: WindowSizeClass = WindowSizeClass(
        WindowSizeClass.WidthSizeClass.Compact,
        WindowSizeClass.HeightSizeClass.Compact,
    ),
)

@Composable
fun currentWindowAdaptiveInfo(): WindowAdaptiveInfo = WindowAdaptiveInfo()
