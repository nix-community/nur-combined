package timber.log

open class Timber {
    open class Tree {
        protected open fun formatMessage(message: String, args: Array<out Any?>): String {
            return if (args.isEmpty()) message else {
                try {
                    String.format(message, *args)
                } catch (_: Throwable) {
                    message
                }
            }
        }

        protected open fun log(priority: Int, tag: String?, message: String, t: Throwable?) {
            val prefix = if (tag != null) "[$tag] " else ""
            val fullMsg = prefix + message
            if (priority >= 5) {
                System.err.println(fullMsg)
                t?.printStackTrace(System.err)
            } else {
                println(fullMsg)
                t?.printStackTrace(System.out)
            }
        }

        open fun v(t: Throwable?, message: String, vararg args: Any?) = log(2, null, formatMessage(message, args), t)
        open fun v(message: String, vararg args: Any?) = log(2, null, formatMessage(message, args), null)
        open fun d(t: Throwable?, message: String, vararg args: Any?) = log(3, null, formatMessage(message, args), t)
        open fun d(message: String, vararg args: Any?) = log(3, null, formatMessage(message, args), null)
        open fun i(t: Throwable?, message: String, vararg args: Any?) = log(4, null, formatMessage(message, args), t)
        open fun i(message: String, vararg args: Any?) = log(4, null, formatMessage(message, args), null)
        open fun w(t: Throwable?, message: String, vararg args: Any?) = log(5, null, formatMessage(message, args), t)
        open fun w(message: String, vararg args: Any?) = log(5, null, formatMessage(message, args), null)
        open fun e(t: Throwable?, message: String, vararg args: Any?) = log(6, null, formatMessage(message, args), t)
        open fun e(message: String, vararg args: Any?) = log(6, null, formatMessage(message, args), null)
        open fun wtf(t: Throwable?, message: String, vararg args: Any?) = log(7, null, formatMessage(message, args), t)
        open fun wtf(message: String, vararg args: Any?) = log(7, null, formatMessage(message, args), null)
    }

    open class TaggedTree(private val tag: String) : Tree() {
        override fun log(priority: Int, tag: String?, message: String, t: Throwable?) {
            super.log(priority, this.tag, message, t)
        }
    }

    open class DebugTree : Tree()

    companion object {
        private val defaultTree = Tree()
        fun plant(tree: Tree) {}
        fun v(t: Throwable?, message: String, vararg args: Any?) = defaultTree.v(t, message, *args)
        fun v(message: String, vararg args: Any?) = defaultTree.v(message, *args)
        fun d(t: Throwable?, message: String, vararg args: Any?) = defaultTree.d(t, message, *args)
        fun d(message: String, vararg args: Any?) = defaultTree.d(message, *args)
        fun i(t: Throwable?, message: String, vararg args: Any?) = defaultTree.i(t, message, *args)
        fun i(message: String, vararg args: Any?) = defaultTree.i(message, *args)
        fun w(t: Throwable?, message: String, vararg args: Any?) = defaultTree.w(t, message, *args)
        fun w(message: String, vararg args: Any?) = defaultTree.w(message, *args)
        fun e(t: Throwable?, message: String, vararg args: Any?) = defaultTree.e(t, message, *args)
        fun e(message: String, vararg args: Any?) = defaultTree.e(message, *args)
        fun wtf(t: Throwable?, message: String, vararg args: Any?) = defaultTree.wtf(t, message, *args)
        fun wtf(message: String, vararg args: Any?) = defaultTree.wtf(message, *args)
        fun tag(tag: String): Tree = TaggedTree(tag)
    }
}
