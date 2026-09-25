package moe.rukamori.archivetune.canvas
import okhttp3.Interceptor
import okhttp3.Response

object CanvasRequestPolicy {
    var check: ((CanvasSource) -> Unit)? = null
    var intercept: ((Interceptor.Chain, CanvasSource) -> Response)? = null
}
