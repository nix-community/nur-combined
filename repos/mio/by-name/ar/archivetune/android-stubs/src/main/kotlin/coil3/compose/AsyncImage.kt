package coil3.compose

import androidx.compose.foundation.Image
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.layout.ContentScale

@Composable
fun AsyncImage(
    model: Any?,
    contentDescription: String?,
    modifier: Any = Any(),
    contentScale: Any = Any(),
    placeholder: Any? = null,
    error: Any? = null,
    fallback: Any? = null,
    alignment: Any = Any(),
    alpha: Float = 1f,
    colorFilter: Any? = null,
    onState: ((coil3.compose.AsyncImagePainter.State) -> Unit)? = null,
    onSuccess: ((coil3.compose.AsyncImagePainter.State.Success) -> Unit)? = null,
    onError: ((coil3.compose.AsyncImagePainter.State.Error) -> Unit)? = null,
) {
    val painter = rememberAsyncImagePainter(
        model = model,
        placeholder = placeholder,
        error = error,
        fallback = fallback,
        onSuccess = onSuccess,
        onError = onError,
        onState = onState,
    )
    val mod = (modifier as? Modifier) ?: Modifier
    val cs = (contentScale as? ContentScale) ?: ContentScale.Fit
    val align = (alignment as? Alignment) ?: Alignment.Center
    val cf = colorFilter as? ColorFilter

    Image(
        painter = painter,
        contentDescription = contentDescription,
        modifier = mod,
        contentScale = cs,
        alignment = align,
        alpha = alpha,
        colorFilter = cf,
    )
}

@Composable
fun SubcomposeAsyncImage(
    model: Any?,
    contentDescription: String?,
    modifier: Any = Any(),
    contentScale: Any = Any(),
    content: @Composable (Any.() -> Unit) = {},
) {
    AsyncImage(
        model = model,
        contentDescription = contentDescription,
        modifier = modifier,
        contentScale = contentScale,
    )
}
