package timber.log


open class Timber {
    open class Tree {
        open fun v(t: Throwable?, message: String, vararg args: Any?) {}
        open fun v(message: String, vararg args: Any?) {}
        open fun w(t: Throwable?, message: String, vararg args: Any?) {}
        open fun w(message: String, vararg args: Any?) {}
        open fun d(message: String, vararg args: Any?) {}
        open fun e(t: Throwable?, message: String, vararg args: Any?) {}
        open fun e(message: String, vararg args: Any?) {}
    }
    open class DebugTree : Tree()
    companion object {
        fun plant(tree: Tree) {}
        fun v(t: Throwable?, message: String, vararg args: Any?) {}
        fun v(message: String, vararg args: Any?) {}
        fun w(t: Throwable?, message: String, vararg args: Any?) {}
        fun w(message: String, vararg args: Any?) {}
        fun d(message: String, vararg args: Any?) {}
        fun e(t: Throwable?, message: String, vararg args: Any?) {}
        fun e(message: String, vararg args: Any?) {}
        fun tag(tag: String): Tree = Tree()
    }
}
