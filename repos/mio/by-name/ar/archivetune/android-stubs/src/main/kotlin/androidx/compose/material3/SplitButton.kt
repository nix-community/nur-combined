package androidx.compose.material3

import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@ExperimentalMaterial3ExpressiveApi
@Composable
fun SplitButtonLayout(
    leadingButton: @Composable () -> Unit,
    trailingButton: @Composable () -> Unit,
    modifier: Modifier = Modifier,
    spacing: Dp = 2.dp
) {
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(spacing),
        verticalAlignment = Alignment.CenterVertically
    ) {
        leadingButton()
        trailingButton()
    }
}

object SplitButtonDefaults {
    val MediumContainerHeight: Dp = 40.dp
    val TrailingIconSize: Dp = 20.dp
    val LeadingIconSize: Dp = 20.dp

    @ExperimentalMaterial3ExpressiveApi
    @Composable
    fun TonalLeadingButton(
        onClick: () -> Unit,
        modifier: Modifier = Modifier,
        enabled: Boolean = true,
        colors: ButtonColors = ButtonDefaults.filledTonalButtonColors(),
        interactionSource: MutableInteractionSource? = null,
        content: @Composable RowScope.() -> Unit
    ) {
        FilledTonalButton(
            onClick = onClick,
            modifier = modifier,
            enabled = enabled,
            colors = colors,
            shape = RoundedCornerShape(topStart = 20.dp, bottomStart = 20.dp, topEnd = 4.dp, bottomEnd = 4.dp),
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
            interactionSource = interactionSource ?: remember { MutableInteractionSource() },
            content = content
        )
    }

    @ExperimentalMaterial3ExpressiveApi
    @Composable
    fun TonalTrailingButton(
        checked: Boolean,
        onCheckedChange: (Boolean) -> Unit,
        modifier: Modifier = Modifier,
        enabled: Boolean = true,
        colors: ButtonColors = ButtonDefaults.filledTonalButtonColors(),
        interactionSource: MutableInteractionSource? = null,
        content: @Composable RowScope.() -> Unit
    ) {
        FilledTonalButton(
            onClick = { onCheckedChange(!checked) },
            modifier = modifier,
            enabled = enabled,
            colors = colors,
            shape = RoundedCornerShape(topStart = 4.dp, bottomStart = 4.dp, topEnd = 20.dp, bottomEnd = 20.dp),
            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 8.dp),
            interactionSource = interactionSource ?: remember { MutableInteractionSource() },
            content = content
        )
    }

    @ExperimentalMaterial3ExpressiveApi
    @Composable
    fun ElevatedLeadingButton(
        onClick: () -> Unit,
        modifier: Modifier = Modifier,
        enabled: Boolean = true,
        colors: ButtonColors = ButtonDefaults.elevatedButtonColors(),
        interactionSource: MutableInteractionSource? = null,
        content: @Composable RowScope.() -> Unit
    ) {
        ElevatedButton(
            onClick = onClick,
            modifier = modifier,
            enabled = enabled,
            colors = colors,
            shape = RoundedCornerShape(topStart = 20.dp, bottomStart = 20.dp, topEnd = 4.dp, bottomEnd = 4.dp),
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
            interactionSource = interactionSource ?: remember { MutableInteractionSource() },
            content = content
        )
    }

    @ExperimentalMaterial3ExpressiveApi
    @Composable
    fun ElevatedTrailingButton(
        checked: Boolean,
        onCheckedChange: (Boolean) -> Unit,
        modifier: Modifier = Modifier,
        enabled: Boolean = true,
        colors: ButtonColors = ButtonDefaults.elevatedButtonColors(),
        interactionSource: MutableInteractionSource? = null,
        content: @Composable RowScope.() -> Unit
    ) {
        ElevatedButton(
            onClick = { onCheckedChange(!checked) },
            modifier = modifier,
            enabled = enabled,
            colors = colors,
            shape = RoundedCornerShape(topStart = 4.dp, bottomStart = 4.dp, topEnd = 20.dp, bottomEnd = 20.dp),
            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 8.dp),
            interactionSource = interactionSource ?: remember { MutableInteractionSource() },
            content = content
        )
    }

    @ExperimentalMaterial3ExpressiveApi
    @Composable
    fun FilledLeadingButton(
        onClick: () -> Unit,
        modifier: Modifier = Modifier,
        enabled: Boolean = true,
        colors: ButtonColors = ButtonDefaults.buttonColors(),
        interactionSource: MutableInteractionSource? = null,
        content: @Composable RowScope.() -> Unit
    ) {
        Button(
            onClick = onClick,
            modifier = modifier,
            enabled = enabled,
            colors = colors,
            shape = RoundedCornerShape(topStart = 20.dp, bottomStart = 20.dp, topEnd = 4.dp, bottomEnd = 4.dp),
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
            interactionSource = interactionSource ?: remember { MutableInteractionSource() },
            content = content
        )
    }

    @ExperimentalMaterial3ExpressiveApi
    @Composable
    fun FilledTrailingButton(
        checked: Boolean,
        onCheckedChange: (Boolean) -> Unit,
        modifier: Modifier = Modifier,
        enabled: Boolean = true,
        colors: ButtonColors = ButtonDefaults.buttonColors(),
        interactionSource: MutableInteractionSource? = null,
        content: @Composable RowScope.() -> Unit
    ) {
        Button(
            onClick = { onCheckedChange(!checked) },
            modifier = modifier,
            enabled = enabled,
            colors = colors,
            shape = RoundedCornerShape(topStart = 4.dp, bottomStart = 4.dp, topEnd = 20.dp, bottomEnd = 20.dp),
            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 8.dp),
            interactionSource = interactionSource ?: remember { MutableInteractionSource() },
            content = content
        )
    }

    @ExperimentalMaterial3ExpressiveApi
    @Composable
    fun OutlinedLeadingButton(
        onClick: () -> Unit,
        modifier: Modifier = Modifier,
        enabled: Boolean = true,
        colors: ButtonColors = ButtonDefaults.outlinedButtonColors(),
        interactionSource: MutableInteractionSource? = null,
        content: @Composable RowScope.() -> Unit
    ) {
        OutlinedButton(
            onClick = onClick,
            modifier = modifier,
            enabled = enabled,
            colors = colors,
            shape = RoundedCornerShape(topStart = 20.dp, bottomStart = 20.dp, topEnd = 4.dp, bottomEnd = 4.dp),
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
            interactionSource = interactionSource ?: remember { MutableInteractionSource() },
            content = content
        )
    }

    @ExperimentalMaterial3ExpressiveApi
    @Composable
    fun OutlinedTrailingButton(
        checked: Boolean,
        onCheckedChange: (Boolean) -> Unit,
        modifier: Modifier = Modifier,
        enabled: Boolean = true,
        colors: ButtonColors = ButtonDefaults.outlinedButtonColors(),
        interactionSource: MutableInteractionSource? = null,
        content: @Composable RowScope.() -> Unit
    ) {
        OutlinedButton(
            onClick = { onCheckedChange(!checked) },
            modifier = modifier,
            enabled = enabled,
            colors = colors,
            shape = RoundedCornerShape(topStart = 4.dp, bottomStart = 4.dp, topEnd = 20.dp, bottomEnd = 20.dp),
            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 8.dp),
            interactionSource = interactionSource ?: remember { MutableInteractionSource() },
            content = content
        )
    }
}
