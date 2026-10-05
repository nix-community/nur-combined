package android.webkit

fun WebView.post(runnable: Runnable): Boolean = true
fun WebView.post(runnable: () -> Unit): Boolean = true
