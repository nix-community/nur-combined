package androidx.compose.material3

import androidx.compose.runtime.Composable
import androidx.compose.animation.core.FiniteAnimationSpec
import androidx.compose.animation.core.snap

@Composable
fun MaterialExpressiveTheme(
    colorScheme: ColorScheme,
    motionScheme: Any? = null,
    typography: Typography,
    shapes: Any? = null,
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = colorScheme,
        typography = typography,
        content = content
    )
}

interface MotionScheme {
    fun <T> defaultSpatialSpec(): FiniteAnimationSpec<T>
    fun <T> fastSpatialSpec(): FiniteAnimationSpec<T>
    fun <T> slowSpatialSpec(): FiniteAnimationSpec<T>
    fun <T> defaultEffectsSpec(): FiniteAnimationSpec<T>
    fun <T> fastEffectsSpec(): FiniteAnimationSpec<T>
    fun <T> slowEffectsSpec(): FiniteAnimationSpec<T>
}

annotation class ExperimentalMaterial3ExpressiveApi

val MaterialTheme.motionScheme: MotionScheme
    @Composable get() = object : MotionScheme {
        override fun <T> defaultSpatialSpec() = snap<T>()
        override fun <T> fastSpatialSpec() = snap<T>()
        override fun <T> slowSpatialSpec() = snap<T>()
        override fun <T> defaultEffectsSpec() = snap<T>()
        override fun <T> fastEffectsSpec() = snap<T>()
        override fun <T> slowEffectsSpec() = snap<T>()
    }
