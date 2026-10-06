package androidx.compose.material3.pulltorefresh

import androidx.compose.runtime.Composable

/*
 * material3 1.9 added PullToRefreshDefaults.LoadingIndicator; the port's compose 1.7 does not.
 * PullToRefreshDefaults is the real object, so this is an extension that fix_theme.py imports
 * where upstream calls it without one.
 */
@OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)
@Composable
fun PullToRefreshDefaults.LoadingIndicator(
    modifier: Any = Any(),
    color: Any = Any(),
    containerColor: Any = Any(),
    isRefreshing: Boolean = false,
    state: Any? = null,
    content: (@Composable () -> Unit)? = null,
) {
    content?.invoke()
}
