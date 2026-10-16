package coil3.compose

import androidx.compose.runtime.State
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.painter.BitmapPainter
import androidx.compose.ui.graphics.painter.Painter
import coil3.Image

abstract class AsyncImagePainter : Painter() {
    abstract val painterState: androidx.compose.runtime.State<Any>

    open val state: State get() = painterState.value as State

    open val painter: Painter? get() = null

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

class DesktopAsyncImagePainter(
    val model: Any?,
    val placeholderPainter: Painter? = null,
    val errorPainter: Painter? = null,
    val fallbackPainter: Painter? = null,
    val onState: ((AsyncImagePainter.State) -> Unit)? = null,
    val onSuccess: ((AsyncImagePainter.State.Success) -> Unit)? = null,
    val onError: ((AsyncImagePainter.State.Error) -> Unit)? = null,
) : AsyncImagePainter() {
    private val _state = mutableStateOf<Any>(AsyncImagePainter.State.Empty())
    override val painterState: androidx.compose.runtime.State<Any> = _state

    var currentPainter: Painter? by mutableStateOf(null)
    override val painter: Painter? get() = currentPainter

    override val intrinsicSize: Size
        get() = currentPainter?.intrinsicSize ?: Size.Unspecified

    private var drawAlpha: Float = 1f
    private var drawColorFilter: ColorFilter? = null

    override fun applyAlpha(alpha: Float): Boolean {
        drawAlpha = alpha
        return true
    }

    override fun applyColorFilter(colorFilter: ColorFilter?): Boolean {
        drawColorFilter = colorFilter
        return true
    }

    override fun DrawScope.onDraw() {
        currentPainter?.run {
            draw(size, drawAlpha, drawColorFilter)
        }
    }

    fun updateState(newState: AsyncImagePainter.State) {
        _state.value = newState
        when (newState) {
            is AsyncImagePainter.State.Success -> {
                val img = (newState.image as? Image)?.imageBitmap
                    ?: (newState.image as? ImageBitmap)
                if (img != null) {
                    currentPainter = BitmapPainter(img)
                }
                onState?.invoke(newState)
                onSuccess?.invoke(newState)
            }
            is AsyncImagePainter.State.Error -> {
                currentPainter = errorPainter
                onState?.invoke(newState)
                onError?.invoke(newState)
            }
            is AsyncImagePainter.State.Loading -> {
                currentPainter = placeholderPainter
                onState?.invoke(newState)
            }
            is AsyncImagePainter.State.Empty -> {
                currentPainter = fallbackPainter
                onState?.invoke(newState)
            }
        }
    }
}
