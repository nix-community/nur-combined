package androidx.navigation

open class NavController {
    open fun navigate(route: String) {}
    open fun navigate(route: String, builder: NavOptionsBuilder.() -> Unit) {}
    open fun popBackStack(): Boolean = false
    open fun popBackStack(route: String, inclusive: Boolean): Boolean = false
    open fun navigateUp(): Boolean = false
    open fun currentBackStackEntry(): NavBackStackEntry? = null
    val currentBackStackEntry: NavBackStackEntry? get() = null
    val previousBackStackEntry: NavBackStackEntry? get() = null
}

open class NavHostController : NavController()

open class NavDestination {
    val route: String? = null
}

open class NavBackStackEntry {
    val arguments: android.os.Bundle? = null
    val savedStateHandle: androidx.lifecycle.SavedStateHandle = androidx.lifecycle.SavedStateHandle()
    val destination: NavDestination? = null
}

class NavOptionsBuilder {
    fun popUpTo(route: String, inclusive: Boolean = false, block: PopUpToBuilder.() -> Unit = {}) {}
    var launchSingleTop: Boolean = false
    var restoreState: Boolean = false
}

class PopUpToBuilder {
    var inclusive: Boolean = false
    var saveState: Boolean = false
}
