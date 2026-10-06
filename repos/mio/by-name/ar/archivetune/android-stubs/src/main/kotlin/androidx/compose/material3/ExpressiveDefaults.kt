package androidx.compose.material3

import androidx.compose.runtime.Composable

// Material3-expressive app-bar and *Defaults.shapes surface missing from
// material3-desktop 1.7.0. Signatures mirror LargeFlexibleTopAppBar so the
// upstream call sites (named arguments) resolve; bodies only invoke the slots.

@ExperimentalMaterial3ExpressiveApi
@Composable
fun MediumFlexibleTopAppBar(
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

fun ButtonDefaults.shapes(shape: Any = Any(), pressedShape: Any = Any()): androidx.compose.ui.graphics.Shape =
    androidx.compose.ui.graphics.RectangleShape

fun IconButtonDefaults.shapes(shape: Any = Any(), pressedShape: Any = Any()): androidx.compose.ui.graphics.Shape =
    androidx.compose.ui.graphics.RectangleShape

/*
 * material3 1.9's IconButton takes a `shape`; the port's compose 1.7 does not. This overload is
 * additive, so calls without `shape` still resolve to the real IconButton.
 */
@ExperimentalMaterial3ExpressiveApi
@Composable
fun IconButton(
    onClick: () -> Unit,
    modifier: Any = Any(),
    enabled: Boolean = true,
    colors: Any = Any(),
    interactionSource: Any = Any(),
    shape: androidx.compose.ui.graphics.Shape,
    content: @Composable () -> Unit,
) {
    content()
}

fun FilterChipDefaults.shapes(shape: Any = Any(), selectedShape: Any = Any()): androidx.compose.ui.graphics.Shape =
    androidx.compose.ui.graphics.RectangleShape

// Remaining Material3-expressive surface material3-desktop 1.7.0 does not ship.
// Loose types on purpose: the desktop port only needs upstream call sites to resolve.
@ExperimentalMaterial3ExpressiveApi
@Composable
fun ToggleButton(
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
    modifier: Any = Any(),
    enabled: Boolean = true,
    shapes: Any = Any(),
    colors: Any = Any(),
    content: @Composable () -> Unit = {},
) {
    content()
}

object ToggleButtonDefaults {
    fun shapes(
        checkedShape: Any = Any(),
        uncheckedShape: Any = Any(),
        pressedShape: Any = Any(),
    ): Any = Any()

    fun colors(
        checkedContainerColor: Any = Any(),
        checkedContentColor: Any = Any(),
        containerColor: Any = Any(),
        contentColor: Any = Any(),
    ): Any = Any()

    fun toggleButtonColors(
        checkedContainerColor: Any = Any(),
        checkedContentColor: Any = Any(),
        containerColor: Any = Any(),
        contentColor: Any = Any(),
        disabledCheckedContainerColor: Any = Any(),
        disabledCheckedContentColor: Any = Any(),
        disabledContainerColor: Any = Any(),
        disabledContentColor: Any = Any(),
    ): Any = Any()

    fun shape(shape: Any = Any()): Any = Any()
}

object FloatingToolbarDefaults {
    fun standardFabPlacement(): Any = Any()

    fun vibrantColors(): Any = Any()

    fun standardColors(): Any = Any()

    /* A member (not an extension): upstream calls it as
     * FloatingToolbarDefaults.VibrantFloatingActionButton(...) without importing an extension. */
    @ExperimentalMaterial3ExpressiveApi
    @Composable
    fun VibrantFloatingActionButton(
        onClick: () -> Unit,
        modifier: Any = Any(),
        containerColor: Any = Any(),
        contentColor: Any = Any(),
        content: @Composable () -> Unit = {},
    ) {
        content()
    }
}

@ExperimentalMaterial3ExpressiveApi
@Composable
fun ContainedLoadingIndicator(
    modifier: Any = Any(),
    containerColor: Any = Any(),
    indicatorColor: Any = Any(),
) {}

object WavyProgressIndicatorDefaults {
    val LinearIndeterminateWavelength: Any = Any()
    val LinearIndeterminateWaveSpeed: Any = Any()
    val CircularIndeterminateWavelength: Any = Any()
    val CircularIndeterminateWaveSpeed: Any = Any()

    /* Determinate variants upstream references for its wavy seek bar. */
    val LinearDeterminateWavelength: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp(16f)
    val LinearDeterminateWaveSpeed: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp(8f)
    val LinearContainerHeight: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp(14f)
    val LinearTrackThickness: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp(4f)
    val CircularContainerSize: androidx.compose.ui.unit.Dp = androidx.compose.ui.unit.Dp(48f)

    val ProgressAnimationSpec: androidx.compose.animation.core.AnimationSpec<Float> =
        androidx.compose.animation.core.spring()
}

@ExperimentalMaterial3ExpressiveApi
@Composable
fun HorizontalFloatingToolbar(
    expanded: Boolean,
    modifier: Any = Any(),
    colors: Any = Any(),
    floatingActionButton: (@Composable () -> Unit)? = null,
    content: @Composable () -> Unit = {},
) {
    floatingActionButton?.invoke()
    content()
}

@ExperimentalMaterial3ExpressiveApi
@Composable
fun VerticalFloatingToolbar(
    expanded: Boolean,
    modifier: Any = Any(),
    colors: Any = Any(),
    floatingActionButton: (@Composable () -> Unit)? = null,
    content: @Composable () -> Unit = {},
) {
    floatingActionButton?.invoke()
    content()
}

// Material3-expressive typography tokens. They are members of Typography upstream;
// the port supplies them as extensions, so fix_theme.py injects the imports.
val Typography.titleLargeEmphasized: androidx.compose.ui.text.TextStyle
    get() = titleLarge

val Typography.titleMediumEmphasized: androidx.compose.ui.text.TextStyle
    get() = titleMedium

val Typography.labelLargeEmphasized: androidx.compose.ui.text.TextStyle
    get() = labelLarge

val Typography.labelMediumEmphasized: androidx.compose.ui.text.TextStyle
    get() = labelMedium

val Typography.bodyLargeEmphasized: androidx.compose.ui.text.TextStyle
    get() = bodyLarge

val Typography.bodyMediumEmphasized: androidx.compose.ui.text.TextStyle
    get() = bodyMedium

val Typography.headlineSmallEmphasized: androidx.compose.ui.text.TextStyle
    get() = headlineSmall

@ExperimentalMaterial3ExpressiveApi
@Composable
fun VibrantFloatingActionButton(
    onClick: () -> Unit,
    modifier: Any = Any(),
    content: @Composable () -> Unit = {},
) {
    content()
}

fun FloatingToolbarDefaults.standardFloatingToolbarColors(
    toolbarContainerColor: Any? = null,
    toolbarContentColor: Any? = null,
    fabContainerColor: Any? = null,
    fabContentColor: Any? = null,
    vararg other: Any?,
): Any = Any()

fun FloatingToolbarDefaults.vibrantFloatingToolbarColors(): Any = Any()

/* Upstream places a vibrant FAB inside a floating toolbar as
 * FloatingToolbarDefaults.VibrantFloatingActionButton(...). */
@ExperimentalMaterial3ExpressiveApi
@Composable
fun FloatingToolbarDefaults.VibrantFloatingActionButton(
    onClick: () -> Unit,
    modifier: Any = Any(),
    containerColor: Any = Any(),
    contentColor: Any = Any(),
    content: @Composable () -> Unit = {},
) {
    content()
}

fun IconButtonDefaults.standardIconButtonColors(): Any = Any()

@ExperimentalMaterial3ExpressiveApi
@Composable
fun FloatingActionButtonMenu(
    expanded: Boolean,
    button: @Composable () -> Unit,
    modifier: Any = Any(),
    content: @Composable () -> Unit = {},
) {
    button()
    content()
}

@ExperimentalMaterial3ExpressiveApi
@Composable
fun FloatingActionButtonMenuItem(
    onClick: () -> Unit,
    icon: @Composable () -> Unit,
    text: @Composable () -> Unit,
    modifier: Any = Any(),
) {
    icon()
    text()
}
