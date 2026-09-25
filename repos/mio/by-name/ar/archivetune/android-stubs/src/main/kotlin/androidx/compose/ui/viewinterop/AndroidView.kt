package androidx.compose.ui.viewinterop

import android.content.Context
import androidx.compose.runtime.Composable

@Composable
fun <T> AndroidView(
    factory: (Context) -> T,
    modifier: Any = Any(),
    update: (T) -> Unit = {}
) {}
