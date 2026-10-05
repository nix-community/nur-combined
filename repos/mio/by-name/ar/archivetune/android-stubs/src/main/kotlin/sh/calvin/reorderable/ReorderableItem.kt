package sh.calvin.reorderable

import androidx.compose.runtime.Composable

@Composable
fun ReorderableItem(
    state: Any,
    key: Any?,
    modifier: Any = Any(),
    content: @Composable () -> Unit
) {
    content()
}

@Composable
fun ReorderableItem(
    state: Any,
    key: Any?,
    content: @Composable () -> Unit
) {
    content()
}

class ItemPosition(val index: Int)

@Composable
fun rememberReorderableLazyListState(
    lazyListState: Any,
    onMove: (from: ItemPosition, to: ItemPosition) -> Unit
): Any = Any()

fun Any.draggableHandle(
    onDragStarted: Any? = null,
    onDragStopped: Any? = null,
    interactionSource: Any? = null
): Any = this
