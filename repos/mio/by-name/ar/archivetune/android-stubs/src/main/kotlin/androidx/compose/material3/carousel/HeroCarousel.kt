package androidx.compose.material3.carousel

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.shape.GenericShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.graphics.Shape
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
    get() = try {
        itemCountState.value.invoke()
    } catch (_: Throwable) {
        0
    }

@OptIn(ExperimentalMaterial3Api::class)
private val desktopCarouselItemInfo: CarouselItemInfo by lazy {
    java.lang.reflect.Proxy.newProxyInstance(
        CarouselItemInfo::class.java.classLoader,
        arrayOf(CarouselItemInfo::class.java),
    ) { proxy, method, args ->
        when (method.name) {
            "getSize" -> 1000f
            "getMinSize" -> 0f
            "getMaxSize" -> 10000f
            "getMaskRect" -> Rect(0f, 0f, 10000f, 10000f)
            "toString" -> "DesktopCarouselItemInfo"
            "hashCode" -> 42
            "equals" -> args?.getOrNull(0) === proxy
            else -> null
        }
    } as CarouselItemInfo
}

@OptIn(ExperimentalMaterial3Api::class)
private val desktopCarouselItemScope: CarouselItemScope by lazy {
    java.lang.reflect.Proxy.newProxyInstance(
        CarouselItemScope::class.java.classLoader,
        arrayOf(CarouselItemScope::class.java),
    ) { proxy, method, args ->
        when {
            method.name.startsWith("getCarouselItemInfo") -> desktopCarouselItemInfo
            method.name.startsWith("maskClip") && args != null && args.size >= 2 -> {
                val modifier = args[0] as? Modifier ?: Modifier
                val shape = args[1] as? Shape
                if (shape != null) {
                    modifier.clip(shape)
                } else {
                    modifier
                }
            }
            method.name.startsWith("maskBorder") && args != null && args.size >= 3 -> {
                val modifier = args[0] as? Modifier ?: Modifier
                val border = args[1] as? BorderStroke
                val shape = args[2] as? Shape
                if (border != null && shape != null) {
                    modifier.border(border, shape)
                } else {
                    modifier
                }
            }
            method.name.startsWith("rememberMaskShape") -> {
                GenericShape { size, _ ->
                    addRect(Rect(0f, 0f, size.width, size.height))
                }
            }
            method.name == "toString" -> "DesktopCarouselItemScope"
            method.name == "hashCode" -> 42
            method.name == "equals" -> args?.getOrNull(0) === proxy
            else -> null
        }
    } as CarouselItemScope
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
    val count = state.itemCount
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
