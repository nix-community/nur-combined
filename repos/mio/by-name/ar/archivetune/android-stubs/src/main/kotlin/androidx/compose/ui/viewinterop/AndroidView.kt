package androidx.compose.ui.viewinterop

import android.content.Context
import androidx.compose.runtime.Composable

/*
 * Compose's AndroidView interop. `onRelease`/`onReset` are part of the real signature;
 * without them upstream's `AndroidView(factory = ..., onRelease = { releasedWebView -> ... })`
 * cannot infer `T`, and every member access on the released view cascades into
 * "unresolved reference" errors.
 */
@Composable
fun <T> AndroidView(
    factory: (Context) -> T,
    modifier: Any = Any(),
    update: (T) -> Unit = {},
    onRelease: (T) -> Unit = {},
    onReset: ((T) -> Unit)? = null,
) {}
