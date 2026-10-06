package androidx.lifecycle

import kotlinx.coroutines.cancel

open class ViewModel {
    open fun onCleared() {
        scopes.remove(this)?.cancel()
    }
}
