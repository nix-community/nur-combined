package coil3.compose

import androidx.compose.runtime.Composable

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
) {}

@Composable
fun SubcomposeAsyncImage(
    model: Any?,
    contentDescription: String?,
    modifier: Any = Any(),
    contentScale: Any = Any(),
    content: @Composable (Any.() -> Unit) = {},
) {}
