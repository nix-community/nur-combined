package androidx.lifecycle

open class LifecycleRegistry(provider: LifecycleOwner) : Lifecycle() {
    override var currentState: State = State.RESUMED
    
    fun handleLifecycleEvent(event: Event) {
    }

    companion object {
        @JvmStatic fun createUnsafe(owner: LifecycleOwner): LifecycleRegistry = LifecycleRegistry(owner)
    }
}
