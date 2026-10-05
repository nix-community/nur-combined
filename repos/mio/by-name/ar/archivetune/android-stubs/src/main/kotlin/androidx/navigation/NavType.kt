package androidx.navigation

open class NavType<T> {
    companion object {
        val StringType: NavType<String?> get() = NavType()
        val IntType: NavType<Int> get() = NavType()
        val LongType: NavType<Long> get() = NavType()
        val BoolType: NavType<Boolean> get() = NavType()
        val FloatType: NavType<Float> get() = NavType()
    }
}

class NamedNavArgument(val name: String, val argument: Any)

fun navArgument(name: String, builder: NavArgumentBuilder.() -> Unit): NamedNavArgument =
    NamedNavArgument(name, Any())

class NavArgumentBuilder {
    var type: Any = NavType.StringType
    var nullable: Boolean = false
    var defaultValue: Any? = null
}
