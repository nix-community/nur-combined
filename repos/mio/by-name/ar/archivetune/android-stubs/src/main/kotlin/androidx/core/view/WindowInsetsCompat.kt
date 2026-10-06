package androidx.core.view

/*
 * androidx.core's WindowInsetsCompat. Upstream reads
 * ViewCompat.getRootWindowInsets(view)?.getInsets(Type.systemGestures() or Type.navigationBars())
 * and then the insets' left/right, so Type is a direct nested object (not on the companion) and
 * getInsets must return a typed Insets.
 */
open class WindowInsetsCompat {
    fun getInsets(typeMask: Int): Insets = Insets()

    fun getInsetsIgnoringVisibility(typeMask: Int): Insets = Insets()

    fun isVisible(typeMask: Int): Boolean = false

    class Insets(
        val left: Int = 0,
        val top: Int = 0,
        val right: Int = 0,
        val bottom: Int = 0,
    )

    object Type {
        @JvmStatic
        fun systemBars(): Int = 1

        @JvmStatic
        fun systemGestures(): Int = 2

        @JvmStatic
        fun navigationBars(): Int = 4

        @JvmStatic
        fun statusBars(): Int = 8

        @JvmStatic
        fun ime(): Int = 16

        @JvmStatic
        fun displayCutout(): Int = 32
    }
}
