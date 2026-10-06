package androidx.media3.common

// Minimal Tracks surface: Player.Listener.onTracksChanged takes it, and upstream
// overrides that listener method, so the type must exist with a matching signature.
open class Tracks {
    open val groups: List<Group> = emptyList()

    open val isEmpty: Boolean
        get() = groups.isEmpty()

    open class Group {
        open val isSelected: Boolean = false

        open val length: Int = 0
    }
}
