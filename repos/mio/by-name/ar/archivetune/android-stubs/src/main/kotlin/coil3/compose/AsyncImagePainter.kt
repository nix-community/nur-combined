package coil3.compose

import androidx.compose.runtime.State
import androidx.compose.ui.graphics.painter.Painter

/*
 * coil3.compose's painter. The real coil3 JVM artifact cannot be used (upstream targets
 * Android and uses Android-only coil3 APIs the JVM publication does not ship), so the
 * port keeps the type surface; it never paints anything.
 */
abstract class AsyncImagePainter : Painter() {
    abstract val painterState: androidx.compose.runtime.State<Any>

    val painter: Painter? = null
    /** coil3's result hierarchy, referenced as `AsyncImagePainter.State.*`. */
    sealed interface State {
        class Empty : State

        class Loading : State

        data class Success(val image: Any? = null) : State

        data class Error(val result: Any? = null) : State
    }

    companion object {
        val DefaultTransform: Any = Any()
    }
}
