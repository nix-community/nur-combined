package androidx.navigationevent.compose

import androidx.compose.runtime.staticCompositionLocalOf
import androidx.navigationevent.NavigationEventDispatcherOwner

val LocalNavigationEventDispatcherOwner =
    staticCompositionLocalOf<NavigationEventDispatcherOwner?> { null }
