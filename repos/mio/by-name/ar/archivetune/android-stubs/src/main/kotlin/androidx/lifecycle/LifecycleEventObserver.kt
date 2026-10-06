package androidx.lifecycle

/*
 * Upstream builds observers with a SAM lambda (`LifecycleEventObserver { _, event -> ... }`),
 * which only compiles if this is a functional interface.
 */
fun interface LifecycleEventObserver {
    fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event)
}
