package androidx.compose.material3.carousel

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/*
 * HorizontalCenteredHeroCarousel is an experimental Android Material3 API not present
 * in material3-desktop 1.7.0. We implement it using LazyRow and the real material3-desktop CarouselState.
 *
 * NOTE: This file is named HeroCarousel.kt (not Carousel.kt) so that its generated class
 * HeroCarouselKt does not shadow material3-desktop's CarouselKt.class.
 */

@OptIn(ExperimentalMaterial3Api::class)
val CarouselState.currentItem: Int
    get() = try {
        val pagerState = this.javaClass.methods.firstOrNull { it.name.startsWith("getPagerState") }?.invoke(this) as? androidx.compose.foundation.pager.PagerState
        pagerState?.currentPage ?: 0
    } catch (_: Throwable) {
        0
    }

@OptIn(ExperimentalMaterial3Api::class)
val CarouselState.itemCount: Int
    get() = itemCountState.value.invoke()

@OptIn(ExperimentalMaterial3Api::class)
private val desktopCarouselItemScope: CarouselItemScope by lazy {
    try {
        val infoClass = Class.forName("androidx.compose.material3.carousel.CarouselItemInfoImpl")
        val scopeClass = Class.forName("androidx.compose.material3.carousel.CarouselItemScopeImpl")
        val info = infoClass.getDeclaredConstructor().newInstance()
        val ctor = scopeClass.declaredConstructors.first()
        ctor.isAccessible = true
        ctor.newInstance(info) as CarouselItemScope
    } catch (_: Throwable) {
        java.lang.reflect.Proxy.newProxyInstance(
            CarouselItemScope::class.java.classLoader,
            arrayOf(CarouselItemScope::class.java),
        ) { _, method, args ->
            if (method.name.startsWith("maskClip") && args != null && args.isNotEmpty()) {
                args[0]
            } else null
        } as CarouselItemScope
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HorizontalCenteredHeroCarousel(
    state: CarouselState,
    maxItemWidth: Dp,
    modifier: Modifier = Modifier,
    itemSpacing: Dp = 0.dp,
    contentPadding: PaddingValues = PaddingValues(0.dp),
    content: @Composable CarouselItemScope.(Int) -> Unit,
) {
    val count = state.itemCountState.value.invoke()
    LazyRow(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(itemSpacing),
        contentPadding = contentPadding,
    ) {
        items(count) { index ->
            Box(modifier = Modifier.width(maxItemWidth)) {
                desktopCarouselItemScope.content(index)
            }
        }
    }
}
