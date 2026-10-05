package androidx.compose.material3

import androidx.compose.runtime.Composable

@ExperimentalMaterial3ExpressiveApi
@Composable
fun LargeFlexibleTopAppBar(
    title: @Composable () -> Unit,
    modifier: Any = Any(),
    subtitle: @Composable () -> Unit = {},
    navigationIcon: @Composable () -> Unit = {},
    actions: @Composable Any.() -> Unit = {},
    windowInsets: Any = Any(),
    colors: Any = Any(),
    scrollBehavior: Any? = null
) {
    title()
    subtitle()
    navigationIcon()
}
