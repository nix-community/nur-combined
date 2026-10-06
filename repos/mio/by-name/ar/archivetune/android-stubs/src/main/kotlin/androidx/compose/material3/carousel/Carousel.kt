package androidx.compose.material3.carousel

import androidx.compose.runtime.Composable

/*
 * Material3's carousel is not in material3-desktop 1.7.0. The port keeps the shape
 * upstream's hero carousel call sites use; no carousel is drawn.
 */
class CarouselState(val currentItem: Int = 0, val itemCount: Int = 0)

fun rememberCarouselState(
    itemCount: () -> Int,
    initialItem: Int = 0,
): CarouselState = CarouselState(itemCount = itemCount())

@Composable
fun HorizontalCenteredHeroCarousel(
    state: CarouselState,
    maxItemWidth: Any,
    itemSpacing: Any = Any(),
    contentPadding: Any = Any(),
    modifier: Any = Any(),
    content: @Composable (Int) -> Unit = {},
) {
}

@Composable
fun HorizontalMultiBrowseCarousel(
    state: CarouselState,
    preferredItemWidth: Any,
    itemSpacing: Any = Any(),
    contentPadding: Any = Any(),
    modifier: Any = Any(),
    content: @Composable (Int) -> Unit = {},
) {
}

@Composable
fun HorizontalUncontainedCarousel(
    state: CarouselState,
    itemWidth: Any,
    itemSpacing: Any = Any(),
    contentPadding: Any = Any(),
    modifier: Any = Any(),
    content: @Composable (Int) -> Unit = {},
) {
}
