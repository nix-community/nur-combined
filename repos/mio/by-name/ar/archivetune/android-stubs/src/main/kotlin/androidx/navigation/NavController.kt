package androidx.navigation

import androidx.compose.runtime.mutableStateListOf

open class NavDestination(val route: String? = null) {
    companion object
}

val NavDestination.hierarchy: Sequence<NavDestination>
    get() = sequenceOf(this)

open class NavBackStackEntry(
    val destination: NavDestination = NavDestination(),
    val arguments: android.os.Bundle? = null,
    val savedStateHandle: androidx.lifecycle.SavedStateHandle = androidx.lifecycle.SavedStateHandle()
)

class NavOptionsBuilder {
    var popUpToRoute: String? = null
    var popUpToInclusive: Boolean = false
    var launchSingleTop: Boolean = false
    var restoreState: Boolean = false

    fun popUpTo(route: String, inclusive: Boolean = false, block: PopUpToBuilder.() -> Unit = {}) {
        popUpToRoute = route
        popUpToInclusive = inclusive
        val builder = PopUpToBuilder().apply(block)
        if (builder.inclusive) {
            popUpToInclusive = true
        }
    }
}

class PopUpToBuilder {
    var inclusive: Boolean = false
    var saveState: Boolean = false
}

open class NavController {
    /* Upstream reaches the ambient Context through the controller. */
    val context: android.content.Context get() = android.content.DummyContext()

    val backQueue = mutableStateListOf<NavBackStackEntry>()

    val currentBackStackEntry: NavBackStackEntry?
        get() = backQueue.lastOrNull()

    val previousBackStackEntry: NavBackStackEntry?
        get() = if (backQueue.size > 1) backQueue[backQueue.size - 2] else null

    open fun navigate(route: String) {
        navigate(route) {}
    }

    open fun navigate(route: String, builder: NavOptionsBuilder.() -> Unit) {
        val options = NavOptionsBuilder().apply(builder)
        if (options.popUpToRoute != null) {
            popBackStack(options.popUpToRoute!!, options.popUpToInclusive)
        }
        if (options.launchSingleTop && currentBackStackEntry?.destination?.route == route) {
            return
        }
        val entry = createBackStackEntry(route)
        backQueue.add(entry)
    }

    open fun popBackStack(): Boolean {
        if (backQueue.size > 1) {
            backQueue.removeAt(backQueue.lastIndex)
            return true
        }
        return false
    }

    open fun popBackStack(route: String, inclusive: Boolean): Boolean {
        val cleanTarget = route.substringBefore("?")
        val idx = backQueue.indexOfLast {
            val entryRoute = it.destination.route?.substringBefore("?") ?: ""
            entryRoute == cleanTarget || entryRoute.startsWith("$cleanTarget/")
        }
        if (idx >= 0) {
            val removeIdx = if (inclusive) idx else idx + 1
            while (backQueue.size > removeIdx && backQueue.size > 1) {
                backQueue.removeAt(backQueue.lastIndex)
            }
            return true
        }
        return false
    }

    open fun navigateUp(): Boolean = popBackStack()

    open fun currentBackStackEntry(): NavBackStackEntry? = currentBackStackEntry

    private fun createBackStackEntry(route: String): NavBackStackEntry {
        val bundle = android.os.Bundle()
        if (route.contains("?")) {
            val parts = route.split("?", limit = 2)
            val query = parts[1]
            query.split("&").forEach { param ->
                val kv = param.split("=", limit = 2)
                if (kv.size == 2) {
                    try {
                        bundle.putString(kv[0], java.net.URLDecoder.decode(kv[1], "UTF-8"))
                    } catch (_: Throwable) {
                        bundle.putString(kv[0], kv[1])
                    }
                }
            }
        }
        return NavBackStackEntry(
            destination = NavDestination(route),
            arguments = bundle
        )
    }
}

open class NavHostController : NavController()
