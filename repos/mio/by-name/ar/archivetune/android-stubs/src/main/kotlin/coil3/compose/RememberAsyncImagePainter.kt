package coil3.compose

import androidx.compose.runtime.Composable

/*
 * coil3.compose's painter factory; upstream calls
 * rememberAsyncImagePainter(model = ..., contentScale = ...) and renders the result.
 */
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
): AsyncImagePainter = TODO("desktop port has no image painter")
