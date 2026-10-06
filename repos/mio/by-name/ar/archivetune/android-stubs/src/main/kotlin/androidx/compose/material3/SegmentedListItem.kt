package androidx.compose.material3

import androidx.compose.runtime.Composable

@ExperimentalMaterial3ExpressiveApi
@Composable
fun SegmentedListItem(
    selected: Boolean = false,
    checked: Boolean = false,
    onCheckedChange: ((Boolean) -> Unit)? = null,
    onClick: () -> Unit = {},
    onLongClick: (() -> Unit)? = null,
    onLongClickLabel: String? = null,
    enabled: Boolean = true,
    shapes: Any? = null,
    contentPadding: Any? = null,
    verticalAlignment: Any? = null,
    colors: Any? = null,
    modifier: Any = Any(),
    overlineContent: (@Composable () -> Unit)? = null,
    supportingContent: (@Composable () -> Unit)? = null,
    leadingContent: (@Composable () -> Unit)? = null,
    trailingContent: (@Composable () -> Unit)? = null,
    content: (@Composable () -> Unit)? = null,
    headlineContent: (@Composable () -> Unit)? = null,
) {}
