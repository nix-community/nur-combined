package coil3.compose

import androidx.compose.runtime.*
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.painter.BitmapPainter
import androidx.compose.ui.graphics.painter.Painter
import coil3.DesktopImageLoader
import coil3.Image
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

private fun toPainter(obj: Any?): Painter? = when (obj) {
    is Painter -> obj
    is ImageBitmap -> BitmapPainter(obj)
    else -> null
}

@Composable
fun rememberAsyncImagePainter(
    model: Any?,
    imageLoader: Any? = null,
    placeholder: Any? = null,
    error: Any? = null,
    fallback: Any? = null,
    onSuccess: ((AsyncImagePainter.State.Success) -> Unit)? = null,
    onError: ((AsyncImagePainter.State.Error) -> Unit)? = null,
    contentScale: Any = Any(),
    contentDescription: String? = null,
    alignment: Any = Any(),
    onState: ((AsyncImagePainter.State) -> Unit)? = null,
    filterQuality: Any = Any(),
): AsyncImagePainter {
    val placeholderPainter = toPainter(placeholder)
    val errorPainter = toPainter(error)
    val fallbackPainter = toPainter(fallback)

    val resolvedData = remember(model) { DesktopImageLoader.resolveModel(model) }
    val cacheKey = remember(resolvedData) { DesktopImageLoader.getCacheKey(resolvedData) }

    val painter = remember(model) {
        DesktopAsyncImagePainter(
            model = model,
            placeholderPainter = placeholderPainter,
            errorPainter = errorPainter,
            fallbackPainter = fallbackPainter,
            onState = onState,
            onSuccess = onSuccess,
            onError = onError,
        ).apply {
            val cached = DesktopImageLoader.getMemoryCached(cacheKey)
            if (cached != null) {
                updateState(AsyncImagePainter.State.Success(Image(imageBitmap = cached.imageBitmap, bitmap = cached.bitmap)))
            } else if (resolvedData == null) {
                updateState(AsyncImagePainter.State.Empty())
            } else {
                updateState(AsyncImagePainter.State.Loading())
            }
        }
    }

    LaunchedEffect(model) {
        if (resolvedData == null) {
            painter.updateState(AsyncImagePainter.State.Empty())
            return@LaunchedEffect
        }
        val cached = DesktopImageLoader.getMemoryCached(cacheKey)
        if (cached != null) {
            painter.updateState(AsyncImagePainter.State.Success(Image(imageBitmap = cached.imageBitmap, bitmap = cached.bitmap)))
            return@LaunchedEffect
        }

        painter.updateState(AsyncImagePainter.State.Loading())
        try {
            val loaded = withContext(Dispatchers.IO) {
                DesktopImageLoader.load(resolvedData)
            }
            if (loaded != null) {
                painter.updateState(AsyncImagePainter.State.Success(Image(imageBitmap = loaded.imageBitmap, bitmap = loaded.bitmap)))
            } else {
                painter.updateState(AsyncImagePainter.State.Error(RuntimeException("Failed to load image: $resolvedData")))
            }
        } catch (e: Throwable) {
            painter.updateState(AsyncImagePainter.State.Error(e))
        }
    }

    return painter
}

@Composable
fun rememberAsyncImagePainter(
    model: Any?,
    imageLoader: Any? = null,
    transform: Any = Any(),
    onState: ((AsyncImagePainter.State) -> Unit)? = null,
    contentScale: Any = Any(),
    filterQuality: Any = Any(),
): AsyncImagePainter = rememberAsyncImagePainter(
    model = model,
    imageLoader = imageLoader,
    contentScale = contentScale,
    onState = onState,
    filterQuality = filterQuality,
)
