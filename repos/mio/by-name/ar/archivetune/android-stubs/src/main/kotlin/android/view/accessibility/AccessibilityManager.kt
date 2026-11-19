package android.view.accessibility

/** Desktop stand-in for the platform accessibility service. */
open class AccessibilityManager {
    open val isTouchExplorationEnabled: Boolean = false
    open val isEnabled: Boolean = false

    fun interface TouchExplorationStateChangeListener {
        fun onTouchExplorationStateChanged(enabled: Boolean)
    }

    private val listeners = mutableListOf<TouchExplorationStateChangeListener>()

    open fun addTouchExplorationStateChangeListener(listener: TouchExplorationStateChangeListener) {
        listeners += listener
    }

    open fun removeTouchExplorationStateChangeListener(listener: TouchExplorationStateChangeListener) {
        listeners -= listener
    }
}
