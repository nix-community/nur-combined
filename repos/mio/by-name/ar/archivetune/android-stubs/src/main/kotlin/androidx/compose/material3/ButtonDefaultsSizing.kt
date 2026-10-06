package androidx.compose.material3

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.ui.unit.Dp

/*
 * Newer material3 sizing helpers than the port's compose 1.7 line. ButtonDefaults is a real
 * object, so these are extensions; fix_theme.py injects their imports where upstream calls them
 * without one.
 */
val ButtonDefaults.MediumContainerHeight: Dp get() = Dp(56f)

val ButtonDefaults.LargeContainerHeight: Dp get() = Dp(64f)

val ButtonDefaults.SmallContainerHeight: Dp get() = Dp(40f)

/* Newer material3 shape accessors. */
val ButtonDefaults.squareShape: androidx.compose.ui.graphics.Shape
    get() = androidx.compose.ui.graphics.RectangleShape

val ButtonDefaults.circleShape: androidx.compose.ui.graphics.Shape
    get() = androidx.compose.foundation.shape.RoundedCornerShape(percent = 50)

val ButtonDefaults.ExtraSmallContainerHeight: Dp get() = Dp(32f)

fun ButtonDefaults.contentPaddingFor(
    buttonHeight: Dp,
    hasStartIcon: Boolean = false,
    hasEndIcon: Boolean = false,
): PaddingValues = PaddingValues()

fun ButtonDefaults.iconSizeFor(buttonHeight: Dp): Dp = Dp(24f)

fun ButtonDefaults.iconSpacingFor(buttonHeight: Dp): Dp = Dp(8f)

fun ButtonDefaults.textStyleFor(buttonHeight: Dp): androidx.compose.ui.text.TextStyle =
    androidx.compose.ui.text.TextStyle.Default

val ButtonDefaults.SmallContentPadding: PaddingValues get() = PaddingValues()

val ButtonDefaults.MediumContentPadding: PaddingValues get() = PaddingValues()

val ButtonDefaults.LargeContentPadding: PaddingValues get() = PaddingValues()

val ButtonDefaults.ExtraSmallContentPadding: PaddingValues get() = PaddingValues()
