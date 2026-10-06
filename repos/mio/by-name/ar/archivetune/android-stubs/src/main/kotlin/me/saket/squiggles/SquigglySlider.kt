package me.saket.squiggles

/*
 * me.saket.squigglyslider:squigglyslider is not resolvable from Maven Central/JitPack
 * at the version upstream pins, so the port keeps the two declarations the player
 * slider uses. Declared as a class so `SquigglySlider.SquigglesSpec` resolves the same
 * way upstream's nested type does.
 */
class SquigglySlider(
    value: Float,
    valueRange: ClosedFloatingPointRange<Float> = 0f..1f,
    onValueChange: (Float) -> Unit = {},
    onValueChangeFinished: (() -> Unit)? = null,
    colors: Any = Any(),
    modifier: Any = Any(),
    squigglesSpec: Any = Any(),
) {
    class SquigglesSpec(
        val amplitude: Any = Any(),
        val strokeWidth: Any = Any(),
    )
}
