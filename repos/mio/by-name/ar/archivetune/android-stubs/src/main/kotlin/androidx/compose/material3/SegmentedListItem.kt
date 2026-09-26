package androidx.compose.material3

import androidx.compose.runtime.Composable

@ExperimentalMaterial3ExpressiveApi
@Composable
fun SegmentedListItem(
    headlineContent: @Composable () -> Unit,
    modifier: Any = Any(),
    overlineContent: (@Composable () -> Unit)? = null,
    supportingContent: (@Composable () -> Unit)? = null,
    leadingContent: (@Composable () -> Unit)? = null,
    trailingContent: (@Composable () -> Unit)? = null,
) {}
