
package androidx.navigation.compose

import androidx.compose.foundation.layout.Box
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.NavBackStackEntry
import androidx.navigation.NavGraphBuilder
import androidx.navigation.NavHostController

val LocalCurrentBackStackEntry = compositionLocalOf<NavBackStackEntry?> { null }

@Composable
fun rememberNavController(): NavHostController = remember { NavHostController() }

fun matchRoute(pattern: String, actualRoute: String, entry: NavBackStackEntry): Boolean {
    val cleanPattern = pattern.substringBefore("?")
    val cleanActual = actualRoute.substringBefore("?")

    if (cleanPattern == cleanActual) {
        return true
    }

    val patternSegments = cleanPattern.split("/")
    val actualSegments = cleanActual.split("/")

    if (patternSegments.size != actualSegments.size) {
        return false
    }

    val matchedParams = mutableMapOf<String, String>()
    for (i in patternSegments.indices) {
        val p = patternSegments[i]
        val a = actualSegments[i]
        if (p.startsWith("{") && p.endsWith("}")) {
            val paramName = p.substring(1, p.length - 1)
            matchedParams[paramName] = try {
                java.net.URLDecoder.decode(a, "UTF-8")
            } catch (_: Throwable) {
                a
            }
        } else if (p != a) {
            return false
        }
    }

    matchedParams.forEach { (k, v) ->
        entry.arguments?.putString(k, v)
        entry.savedStateHandle[k] = v
    }
    return true
}

@Composable
fun NavHost(
    navController: NavHostController,
    startDestination: String,
    modifier: Modifier = Modifier,
    contentAlignment: androidx.compose.ui.Alignment = androidx.compose.ui.Alignment.Center,
    route: String? = null,
    enterTransition: Any? = null,
    exitTransition: Any? = null,
    popEnterTransition: Any? = null,
    popExitTransition: Any? = null,
    builder: NavGraphBuilder.() -> Unit
) {
    val graph = remember(builder) {
        NavGraphBuilder().apply(builder)
    }

    LaunchedEffect(navController, startDestination) {
        if (navController.backQueue.isEmpty()) {
            navController.navigate(startDestination)
        }
    }

    val currentEntry by navController.currentBackStackEntryAsState()

    Box(modifier = modifier) {
        val entry = currentEntry
        if (entry != null) {
            val currentRoute = entry.destination.route ?: startDestination
            val matchedNode = graph.routes.firstOrNull { node ->
                matchRoute(node.routePattern, currentRoute, entry)
            }
            if (matchedNode != null) {
                CompositionLocalProvider(
                    LocalCurrentBackStackEntry provides entry
                ) {
                    key(entry) {
                        matchedNode.content(entry)
                    }
                }
            }
        }
    }
}
