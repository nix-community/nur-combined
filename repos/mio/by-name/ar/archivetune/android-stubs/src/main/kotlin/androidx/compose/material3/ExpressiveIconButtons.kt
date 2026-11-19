package androidx.compose.material3

import androidx.compose.runtime.Composable

/*
 * material3 1.13 keeps the expressive `shapes`-taking icon-button overloads as
 * deprecated-hidden API, so upstream's calls do not resolve. These loose overloads
 * accept the shapes values the app passes (IconButtonDefaults.shapes() and friends)
 * and render the content.
 */
@ExperimentalMaterial3ExpressiveApi
@Composable
fun IconButton(
    onClick: () -> Unit,
    shapes: Any,
    modifier: Any = Any(),
    enabled: Boolean = true,
    colors: Any = Any(),
    interactionSource: Any = Any(),
    content: @Composable () -> Unit = {},
) {
    content()
}

@ExperimentalMaterial3ExpressiveApi
@Composable
fun FilledIconButton(
    onClick: () -> Unit,
    shapes: Any,
    modifier: Any = Any(),
    enabled: Boolean = true,
    colors: Any = Any(),
    interactionSource: Any = Any(),
    content: @Composable () -> Unit = {},
) {
    content()
}

@ExperimentalMaterial3ExpressiveApi
@Composable
fun FilledTonalIconButton(
    onClick: () -> Unit,
    shapes: Any,
    modifier: Any = Any(),
    enabled: Boolean = true,
    colors: Any = Any(),
    interactionSource: Any = Any(),
    content: @Composable () -> Unit = {},
) {
    content()
}

@ExperimentalMaterial3ExpressiveApi
@Composable
fun OutlinedIconButton(
    onClick: () -> Unit,
    shapes: Any,
    modifier: Any = Any(),
    enabled: Boolean = true,
    colors: Any = Any(),
    border: Any = Any(),
    interactionSource: Any = Any(),
    content: @Composable () -> Unit = {},
) {
    content()
}

@ExperimentalMaterial3ExpressiveApi
@Composable
fun IconToggleButton(
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
    shapes: Any,
    modifier: Any = Any(),
    enabled: Boolean = true,
    colors: Any = Any(),
    interactionSource: Any = Any(),
    content: @Composable () -> Unit = {},
) {
    content()
}

@ExperimentalMaterial3ExpressiveApi
@Composable
fun FilledIconToggleButton(
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
    shapes: Any,
    modifier: Any = Any(),
    enabled: Boolean = true,
    colors: Any = Any(),
    interactionSource: Any = Any(),
    content: @Composable () -> Unit = {},
) {
    content()
}

@ExperimentalMaterial3ExpressiveApi
@Composable
fun FilledTonalIconToggleButton(
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
    shapes: Any,
    modifier: Any = Any(),
    enabled: Boolean = true,
    colors: Any = Any(),
    interactionSource: Any = Any(),
    content: @Composable () -> Unit = {},
) {
    content()
}

@ExperimentalMaterial3ExpressiveApi
@Composable
fun OutlinedIconToggleButton(
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
    shapes: Any,
    modifier: Any = Any(),
    enabled: Boolean = true,
    colors: Any = Any(),
    border: Any = Any(),
    interactionSource: Any = Any(),
    content: @Composable () -> Unit = {},
) {
    content()
}
