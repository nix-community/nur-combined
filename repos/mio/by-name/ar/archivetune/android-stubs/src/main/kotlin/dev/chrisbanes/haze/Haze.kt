package dev.chrisbanes.haze

import androidx.compose.ui.Modifier

/*
 * dev.chrisbanes.haze:haze 2.0.0-rc01 requires a newer Compose Multiplatform than the
 * port pins (1.12.0), so it cannot be a real dependency. The port keeps the small
 * surface ImmersivePlayerScreen uses; no blur is applied.
 */
class HazeState

fun rememberHazeState(): HazeState = HazeState()

interface HazeInput {
    class Sources(val state: HazeState) : HazeInput

    class Elements(vararg val elements: Any) : HazeInput
}

enum class HazePerformanceMode {
    Default,
    Adaptive,
}

enum class HazeStyle {
    Default,
}

fun Modifier.hazeSource(
    state: HazeState,
    zIndex: Float = 0f,
    key: Any? = null,
): Modifier = this

fun Modifier.hazeEffect(
    state: HazeState,
    style: Any = Any(),
    block: (Any) -> Unit = {},
): Modifier = this
