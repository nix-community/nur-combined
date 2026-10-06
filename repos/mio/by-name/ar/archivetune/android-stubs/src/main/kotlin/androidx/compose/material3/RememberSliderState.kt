package androidx.compose.material3

import androidx.compose.runtime.Composable

/*
 * compose 1.7's material3 has SliderState and Slider(state = ...) but not this factory, so
 * upstream's `rememberSliderState(...)` is supplied here. It returns the *real* SliderState type,
 * so calls keep resolving to the real Slider/Track overloads (declaring our own SliderState class
 * made those ambiguous).
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun rememberSliderState(
    value: Float = 0f,
    valueRange: ClosedFloatingPointRange<Float> = 0f..1f,
    steps: Int = 0,
    onValueChangeFinished: (() -> Unit)? = null,
    enabled: Boolean = true,
): SliderState = TODO("desktop port has no slider state")
