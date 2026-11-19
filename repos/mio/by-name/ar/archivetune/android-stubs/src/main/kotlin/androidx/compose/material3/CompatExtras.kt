package androidx.compose.material3

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color

@ExperimentalMaterial3ExpressiveApi
@Composable
fun ContainedLoadingIndicator(
    modifier: Modifier = Modifier,
    containerColor: Color = Color.Unspecified,
    indicatorColor: Color = Color.Unspecified,
) {}

/*
 * 1.13 names the toggle-button colours factory `colors()`; upstream v16 still calls it
 * `toggleButtonColors()`. An extension (not a second object) keeps the real object visible.
 */
@Composable
fun ToggleButtonDefaults.toggleButtonColors(
    containerColor: Color = Color.Unspecified,
    contentColor: Color = Color.Unspecified,
    checkedContainerColor: Color = Color.Unspecified,
    checkedContentColor: Color = Color.Unspecified,
): ToggleButtonColors =
    colors(
        containerColor = containerColor,
        contentColor = contentColor,
        checkedContainerColor = checkedContainerColor,
        checkedContentColor = checkedContentColor,
    )
