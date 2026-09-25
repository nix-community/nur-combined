package okhttp3


interface Call : Cloneable {
    fun enqueue(responseCallback: Callback)
    fun isCanceled(): Boolean = false
    override fun clone(): Call
}

