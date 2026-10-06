package androidx.lifecycle

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import java.util.concurrent.ConcurrentHashMap

internal val scopes = ConcurrentHashMap<ViewModel, CoroutineScope>()

val ViewModel.viewModelScope: CoroutineScope
    get() = scopes.getOrPut(this) { CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate) }
