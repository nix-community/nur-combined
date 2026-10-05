package timber.log

open class Timber {
    open class Tree {
        protected open fun log(priority: Int, tag: String?, message: String, t: Throwable?) {}
        open fun v(t: Throwable?, message: String, vararg args: Any?) {}
        open fun v(message: String, vararg args: Any?) {}
        open fun i(t: Throwable?, message: String, vararg args: Any?) {}
        open fun i(message: String, vararg args: Any?) {}
        open fun w(t: Throwable?, message: String, vararg args: Any?) {}
        open fun w(message: String, vararg args: Any?) {}
        open fun d(t: Throwable?, message: String, vararg args: Any?) {}
        open fun d(message: String, vararg args: Any?) {}
        open fun e(t: Throwable?, message: String, vararg args: Any?) {}
        open fun e(message: String, vararg args: Any?) {}
        open fun wtf(t: Throwable?, message: String, vararg args: Any?) {}
        open fun wtf(message: String, vararg args: Any?) {}
    }
    open class DebugTree : Tree()
    companion object {
        fun plant(tree: Tree) {}
        fun v(t: Throwable?, message: String, vararg args: Any?) {}
        fun v(message: String, vararg args: Any?) {}
        fun i(t: Throwable?, message: String, vararg args: Any?) {}
        fun i(message: String, vararg args: Any?) {}
        fun w(t: Throwable?, message: String, vararg args: Any?) {}
        fun w(message: String, vararg args: Any?) {}
        fun d(t: Throwable?, message: String, vararg args: Any?) {}
        fun d(message: String, vararg args: Any?) {}
        fun e(t: Throwable?, message: String, vararg args: Any?) {}
        fun e(message: String, vararg args: Any?) {}
        fun wtf(t: Throwable?, message: String, vararg args: Any?) {}
        fun wtf(message: String, vararg args: Any?) {}
        fun tag(tag: String): Tree = Tree()
    }
}
