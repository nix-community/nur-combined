package androidx.compose.material3

import androidx.compose.animation.core.FiniteAnimationSpec
import androidx.compose.animation.core.snap
import androidx.compose.runtime.Composable

// Material3-Expressive motion scheme. material3-desktop 1.7.0 has no MotionScheme,
// but the app reads MaterialTheme.motionScheme.<spec>() and MotionScheme.standard()
// all over its animations. The port returns snap() specs everywhere so animations
// are effectively instant.
interface MotionScheme {
    fun <T> defaultSpatialSpec(): FiniteAnimationSpec<T>

    fun <T> fastSpatialSpec(): FiniteAnimationSpec<T>

    fun <T> slowSpatialSpec(): FiniteAnimationSpec<T>

    fun <T> defaultEffectsSpec(): FiniteAnimationSpec<T>

    fun <T> fastEffectsSpec(): FiniteAnimationSpec<T>

    fun <T> slowEffectsSpec(): FiniteAnimationSpec<T>

    companion object {
        fun standard(): MotionScheme = SnapMotionScheme

        fun expressive(): MotionScheme = SnapMotionScheme
    }
}

private object SnapMotionScheme : MotionScheme {
    override fun <T> defaultSpatialSpec() = snap<T>()

    override fun <T> fastSpatialSpec() = snap<T>()

    override fun <T> slowSpatialSpec() = snap<T>()

    override fun <T> defaultEffectsSpec() = snap<T>()

    override fun <T> fastEffectsSpec() = snap<T>()

    override fun <T> slowEffectsSpec() = snap<T>()
}

val MaterialTheme.motionScheme: MotionScheme
    @Composable get() = SnapMotionScheme
