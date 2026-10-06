package androidx.media3.ui.compose

import androidx.compose.runtime.Composable

/*
 * Upstream renders the player surface with
 * ContentFrame(player = ..., surfaceType = ..., contentScale = ..., keepContentOnReset = ...,
 * shutter = {...}, modifier = ...), so this overload must exist alongside the inert class form.
 */
@Composable
fun ContentFrame(
    player: Any,
    modifier: Any = Any(),
    surfaceType: Int = SURFACE_TYPE_SURFACE_VIEW,
    contentScale: Any = Any(),
    keepContentOnReset: Boolean = false,
    shutter: (@Composable () -> Unit)? = null,
) {
    shutter?.invoke()
}
