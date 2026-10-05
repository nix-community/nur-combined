package androidx.compose.material3

import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@ExperimentalMaterial3ExpressiveApi
@Composable
fun SplitButtonLayout(
    leadingButton: @Composable () -> Unit,
    trailingButton: @Composable () -> Unit,
    modifier: Any = Any(),
    spacing: Any = Any()
) {
    leadingButton()
    trailingButton()
}

object SplitButtonDefaults {
    val MediumContainerHeight: Dp = 0.dp
    
    @ExperimentalMaterial3ExpressiveApi
    @Composable
    fun TonalLeadingButton(
        onClick: () -> Unit,
        modifier: Any = Any(),
        enabled: Boolean = true,
        colors: Any = Any(),
        interactionSource: Any = Any(),
        content: @Composable () -> Unit
    ) {
        content()
    }
    
    @ExperimentalMaterial3ExpressiveApi
    @Composable
    fun TonalTrailingButton(
        checked: Boolean,
        onCheckedChange: (Boolean) -> Unit,
        modifier: Any = Any(),
        enabled: Boolean = true,
        colors: Any = Any(),
        interactionSource: Any = Any(),
        content: @Composable () -> Unit
    ) {
        content()
    }
}
