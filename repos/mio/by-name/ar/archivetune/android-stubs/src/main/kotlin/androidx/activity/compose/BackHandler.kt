package androidx.activity.compose

import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberUpdatedState
import java.util.concurrent.CopyOnWriteArrayList

object BackDispatcher {
    private val handlers = CopyOnWriteArrayList<() -> Boolean>()

    fun register(handler: () -> Boolean): () -> Unit {
        handlers.add(0, handler)
        return { handlers.remove(handler) }
    }

    fun handleBack(): Boolean {
        for (handler in handlers) {
            if (handler()) return true
        }
        return false
    }
}

@Composable
fun BackHandler(enabled: Boolean = true, onBack: () -> Unit) {
    val currentOnBack by rememberUpdatedState(onBack)
    DisposableEffect(enabled) {
        if (!enabled) return@DisposableEffect onDispose {}
        val unregister = BackDispatcher.register {
            if (enabled) {
                currentOnBack()
                true
            } else {
                false
            }
        }
        onDispose { unregister() }
    }
}
