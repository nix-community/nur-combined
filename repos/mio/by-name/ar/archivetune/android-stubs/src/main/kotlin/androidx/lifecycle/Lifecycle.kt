package androidx.lifecycle

open class Lifecycle {
    enum class State {
        DESTROYED,
        INITIALIZED,
        CREATED,
        STARTED,
        RESUMED,
        ;

        fun isAtLeast(other: State): Boolean = ordinal >= other.ordinal
    }

    open val currentState: State = State.RESUMED

    enum class Event {
        ON_CREATE,
        ON_START,
        ON_RESUME,
        ON_PAUSE,
        ON_STOP,
        ON_DESTROY,
        ON_ANY,
        ;

        val targetState: State
            get() = when (this) {
                ON_CREATE, ON_STOP -> State.CREATED
                ON_START, ON_PAUSE -> State.STARTED
                ON_RESUME -> State.RESUMED
                ON_DESTROY -> State.DESTROYED
                ON_ANY -> State.CREATED
            }
    }

    fun addObserver(observer: Any) {}

    fun removeObserver(observer: Any) {}

    companion object { }
}
