package com.valentinilk.shimmer

import androidx.compose.ui.Modifier

/*
 * com.valentinilk.shimmer:compose-shimmer is built against a newer Compose
 * Multiplatform than the port pins (it forces compose-ui 1.12.0 / koklin-stdlib-common
 * 2.4.20, incompatible with the port's 1.7.0), so it cannot be used as a real
 * dependency here. The port keeps the theme type and the Modifier extension; nothing
 * shimmers.
 */
class ShimmerTheme(
    val animationSpec: androidx.compose.animation.core.InfiniteRepeatableSpec<Float> =
        androidx.compose.animation.core.infiniteRepeatable(
            animation = androidx.compose.animation.core.tween(),
        ),
    val blendMode: Any = Any(),
    val colors: List<Any> = listOf(Any()),
    val intensity: Float = 0f,
    val rotation: Float = 0f,
    val width: Any = Any(),
    val shimmerSize: Any = Any(),
    val shaderColors: List<Any> = emptyList(),
) {
    fun copy(
        animationSpec: androidx.compose.animation.core.InfiniteRepeatableSpec<Float> = this.animationSpec,
        blendMode: Any = this.blendMode,
        colors: List<Any> = this.colors,
        intensity: Float = this.intensity,
        rotation: Float = this.rotation,
        width: Any = this.width,
        shimmerSize: Any = this.shimmerSize,
        shaderColors: List<Any> = this.shaderColors,
    ): ShimmerTheme =
        ShimmerTheme(animationSpec, blendMode, colors, intensity, rotation, width, shimmerSize, shaderColors)
}

val defaultShimmerTheme: ShimmerTheme = ShimmerTheme()

val ShimmerThemeRange: Any = Any()

fun Modifier.shimmer(
    theme: ShimmerTheme = defaultShimmerTheme,
    clipToBounds: Boolean = true,
    shaderColors: Any? = null,
    shimmerColor: Any? = null,
): Modifier = this
