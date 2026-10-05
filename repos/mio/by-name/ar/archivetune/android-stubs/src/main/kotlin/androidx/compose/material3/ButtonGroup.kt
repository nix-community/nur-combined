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
    
    fun linkedButtonColors(): Any = Any()
    fun connectedButtonColors(): Any = Any()
}
