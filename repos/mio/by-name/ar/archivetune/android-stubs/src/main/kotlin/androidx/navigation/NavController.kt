
package androidx.navigation
open class NavController {
    open fun navigate(route: String) {}
    open fun popBackStack() {}
}
open class NavHostController : NavController()
