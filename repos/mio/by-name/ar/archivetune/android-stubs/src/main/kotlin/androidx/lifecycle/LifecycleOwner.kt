package androidx.lifecycle

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

interface LifecycleOwner {
    val lifecycleScope: CoroutineScope

    // Default getter so existing implementers do not have to provide one.
    val lifecycle: Lifecycle
        get() = Lifecycle()
}

val LifecycleOwner.lifecycleScopeCompat: CoroutineScope
    get() = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
