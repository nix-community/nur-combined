package androidx.window.core.layout

/*
 * androidx.window's WindowSizeClass (a different package from material3-adaptive's).
 * Upstream reads WindowSizeClass.WIDTH_DP_MEDIUM_LOWER_BOUND and calls
 * isWidthAtLeastBreakpoint(...).
 */
class WindowSizeClass {
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
}
