package okhttp3

interface Call {
    fun enqueue(responseCallback: Callback)
    fun cancel()
    val isCanceled: Boolean
}
