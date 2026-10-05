package androidx.compose.material3

import androidx.compose.runtime.Composable

@ExperimentalMaterial3ExpressiveApi
@Composable
fun ShortNavigationBar(
    modifier: Any = Any(),
    containerColor: Any = Any(),
    contentColor: Any = Any(),
    windowInsets: Any = Any(),
    arrangement: Any = Any(),
    content: @Composable () -> Unit
) {
    content()
}

@ExperimentalMaterial3ExpressiveApi
@Composable
fun ShortNavigationBarItem(
    selected: Boolean,
    onClick: () -> Unit,
    icon: @Composable () -> Unit,
    modifier: Any = Any(),
    enabled: Boolean = true,
    label: (@Composable () -> Unit)? = null,
    alwaysShowLabel: Boolean = true,
    colors: Any = Any(),
    interactionSource: Any = Any()
) {}

open class ShortNavigationBarArrangement {
    companion object {
        val EqualWeight: Any = Any()
    }
}
