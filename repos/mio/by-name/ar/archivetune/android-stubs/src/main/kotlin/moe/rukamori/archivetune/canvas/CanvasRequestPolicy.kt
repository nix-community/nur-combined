package moe.rukamori.archivetune.canvas

object CanvasRequestPolicy {
    var check: ((CanvasSource) -> Unit)? = null
    var intercept: ((Any) -> Any)? = null
}
