package kotlinx.coroutines.guava

import com.google.common.util.concurrent.ListenableFuture
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext

fun <T> CoroutineScope.future(
    context: CoroutineContext = EmptyCoroutineContext,
    block: suspend CoroutineScope.() -> T
): ListenableFuture<T> {
    val future = com.google.common.util.concurrent.SettableFuture.create<T>()
    this.launch(context) {
        try {
            future.set(block())
        } catch (e: Throwable) {
            future.setException(e)
        }
    }
    return future
}
