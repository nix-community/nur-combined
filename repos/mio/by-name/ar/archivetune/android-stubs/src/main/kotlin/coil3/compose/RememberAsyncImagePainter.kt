package coil3.compose

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.drawscope.DrawScope

private class EmptyAsyncImagePainter : AsyncImagePainter() {
    override val painterState = androidx.compose.runtime.mutableStateOf<Any>(AsyncImagePainter.State.Empty())
    override val intrinsicSize: Size get() = Size.Unspecified
    override fun DrawScope.onDraw() {}
}

@Composable
fun rememberAsyncImagePainter(
    model: Any?,
    contentDescription: String? = null,
    contentScale: Any = Any(),
    placeholder: Any? = null,
    error: Any? = null,
    fallback: Any? = null,
    alignment: Any = Any(),
    onState: ((AsyncImagePainter.State) -> Unit)? = null,
    filterQuality: Any = Any(),
): AsyncImagePainter = remember { EmptyAsyncImagePainter() }
