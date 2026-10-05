package androidx.navigation.compose

import androidx.compose.runtime.Composable
import androidx.navigation.NavBackStackEntry
import androidx.navigation.NavGraphBuilder
import androidx.navigation.NamedNavArgument

fun NavGraphBuilder.composable(
    route: String,
    arguments: List<NamedNavArgument> = emptyList(),
    deepLinks: List<Any> = emptyList(),
    enterTransition: Any? = null,
    exitTransition: Any? = null,
    popEnterTransition: Any? = null,
    popExitTransition: Any? = null,
    content: @Composable (NavBackStackEntry) -> Unit
) {}

fun NavGraphBuilder.dialog(
    route: String,
    arguments: List<NamedNavArgument> = emptyList(),
    content: @Composable (NavBackStackEntry) -> Unit
) {}
