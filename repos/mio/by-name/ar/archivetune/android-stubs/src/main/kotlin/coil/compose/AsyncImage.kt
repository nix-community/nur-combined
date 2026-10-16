package coil.compose

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
) {
    coil3.compose.AsyncImage(
        model = model,
        contentDescription = contentDescription,
        modifier = modifier,
        contentScale = contentScale,
        placeholder = placeholder,
        error = error,
        fallback = fallback,
        alignment = alignment,
        alpha = alpha,
        colorFilter = colorFilter,
    )
}
