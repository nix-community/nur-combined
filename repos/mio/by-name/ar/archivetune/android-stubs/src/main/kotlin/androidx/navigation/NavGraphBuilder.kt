package androidx.navigation

open class NavGraphBuilder {
    companion object { }
}

fun NavGraphBuilder.navigation(
    startDestination: String,
    route: String,
    builder: NavGraphBuilder.() -> Unit
) {}
