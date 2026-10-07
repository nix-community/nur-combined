package android.content

open class ContextWrapper(context: Context?) : Context() {
    open val baseContext: Context = context ?: DummyContext()
}
