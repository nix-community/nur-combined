package androidx.navigation

import androidx.compose.runtime.Composable

class RouteNode(
    val routePattern: String,
    val arguments: List<NamedNavArgument> = emptyList(),
    val content: @Composable (NavBackStackEntry) -> Unit
)

open class NavGraphBuilder {
    val routes = mutableListOf<RouteNode>()
    companion object { }
}

fun NavGraphBuilder.navigation(
    startDestination: String,
    route: String,
    builder: NavGraphBuilder.() -> Unit
) {
    builder()
}
