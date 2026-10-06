package androidx.navigation.compose

import androidx.compose.runtime.Composable
import androidx.compose.runtime.State
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.navigation.NavBackStackEntry
import androidx.navigation.NavController
import androidx.navigation.NavGraphBuilder
import androidx.navigation.NamedNavArgument

/*
 * The transition lambdas must receive an AnimatedContentTransitionScope receiver: upstream's
 * `exitTransition = { if (targetState.destination...) ... }` reads targetState/initialState off it.
 * Declared as Any? the receiver was unknown and both reads failed.
 */
fun NavGraphBuilder.composable(
    route: String,
    arguments: List<NamedNavArgument> = emptyList(),
    deepLinks: List<Any> = emptyList(),
    enterTransition:
        (androidx.compose.animation.AnimatedContentTransitionScope<NavBackStackEntry>.() -> Any?)? = null,
    exitTransition:
        (androidx.compose.animation.AnimatedContentTransitionScope<NavBackStackEntry>.() -> Any?)? = null,
    popEnterTransition:
        (androidx.compose.animation.AnimatedContentTransitionScope<NavBackStackEntry>.() -> Any?)? = null,
    popExitTransition:
        (androidx.compose.animation.AnimatedContentTransitionScope<NavBackStackEntry>.() -> Any?)? = null,
    content: @Composable (NavBackStackEntry) -> Unit,
) {}

fun NavGraphBuilder.dialog(
    route: String,
    arguments: List<NamedNavArgument> = emptyList(),
    content: @Composable (NavBackStackEntry) -> Unit
) {}

@Composable
fun NavController.currentBackStackEntryAsState(): State<NavBackStackEntry?> =
    remember { mutableStateOf(null) }
