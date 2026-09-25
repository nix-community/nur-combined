package androidx.webkit

object WebViewFeature {
    val DOCUMENT_START_SCRIPT = "DOCUMENT_START_SCRIPT"
    val WEB_MESSAGE_LISTENER = "WEB_MESSAGE_LISTENER"
    val MULTI_PROFILE = "MULTI_PROFILE"
    val SERVICE_WORKER_BLOCK_NETWORK_LOADS = "SERVICE_WORKER_BLOCK_NETWORK_LOADS"
    
    fun isFeatureSupported(feature: String): Boolean = false
}
