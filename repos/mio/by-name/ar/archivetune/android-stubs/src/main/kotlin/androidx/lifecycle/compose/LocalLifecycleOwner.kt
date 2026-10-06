package androidx.lifecycle.compose

import androidx.compose.runtime.ProvidableCompositionLocal
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

/*
 * Upstream reads `LocalLifecycleOwner.current` (a CompositionLocal), not a class, so a
 * stub class made every `.current` access unresolved. Provided here as a real
 * CompositionLocal whose default owner reports a RESUMED lifecycle.
 */
private object DefaultLifecycleOwner : LifecycleOwner {
    override val lifecycleScope: CoroutineScope =
        CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    override val lifecycle: Lifecycle = Lifecycle()
}

val LocalLifecycleOwner: ProvidableCompositionLocal<LifecycleOwner> =
    staticCompositionLocalOf { DefaultLifecycleOwner }
