package androidx.compose.material3

import androidx.compose.runtime.Composable

@ExperimentalMaterial3ExpressiveApi
@Composable
fun SegmentedListItem(
    selected: Boolean = false,
    onClick: () -> Unit = {},
    enabled: Boolean = true,
    shapes: Any? = null,
    colors: Any? = null,
    modifier: Any = Any(),
    overlineContent: (@Composable () -> Unit)? = null,
    supportingContent: (@Composable () -> Unit)? = null,
    leadingContent: (@Composable () -> Unit)? = null,
    trailingContent: (@Composable () -> Unit)? = null,
    content: (@Composable () -> Unit)? = null,
    headlineContent: (@Composable () -> Unit)? = null,
) {}
