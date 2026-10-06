package android.view

/* android.view.Display; upstream picks the fastest refresh mode for its frame-rate cap. */
open class Display {
    val refreshRate: Float = 60f

    val mode: Mode = Mode()

    val supportedModes: Array<Mode> = emptyArray()

    val displayId: Int = 0

    val rotation: Int = 0

    class Mode(val refreshRate: Float = 60f, val modeId: Int = 0)
}
