package androidx.compose.material3

import androidx.compose.runtime.Composable

@ExperimentalMaterial3ExpressiveApi
@Composable
fun ButtonGroup(
    modifier: Any = Any(),
    content: @Composable () -> Unit
) {
    content()
}

object ButtonGroupDefaults {
    val linkedButtonColors: Any = Any()
    val connectedButtonColors: Any = Any()

    /* Newer material3 API than the port's 1.7 line; upstream uses these connected shapes. */
    val ConnectedSpaceBetween: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp(2f)

    fun connectedLeadingButtonShapes(): androidx.compose.ui.graphics.Shape =
        androidx.compose.ui.graphics.RectangleShape

    fun connectedMiddleButtonShapes(): androidx.compose.ui.graphics.Shape =
        androidx.compose.ui.graphics.RectangleShape

    fun connectedTrailingButtonShapes(): androidx.compose.ui.graphics.Shape =
        androidx.compose.ui.graphics.RectangleShape

    fun linkedButtonColors(): Any = Any()
    fun connectedButtonColors(): Any = Any()
}
