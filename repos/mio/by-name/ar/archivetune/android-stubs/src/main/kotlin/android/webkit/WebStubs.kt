package android.webkit

import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.os.Message
import android.view.View
import java.io.InputStream

open class WebView(context: Context) : View(context) {
    open class WebViewTransport {
        var webView: WebView? = null
    }

    open fun loadUrl(url: String) {}
    open fun loadDataWithBaseURL(baseUrl: String?, data: String, mimeType: String?, encoding: String?, historyUrl: String?) {}
    open fun evaluateJavascript(script: String, resultCallback: ((String) -> Unit)? = null) {}
    open fun stopLoading() {}
    open fun destroy() {}
    open fun onPause() {}
    open fun onResume() {}
    open fun clearCache(includeDiskFiles: Boolean) {}
    open fun clearHistory() {}
    open fun clearFormData() {}
    open fun removeAllViews() {}
    open fun addJavascriptInterface(obj: Any, name: String) {}
    open fun removeJavascriptInterface(name: String) {}
    open fun canGoBack(): Boolean = false
    open fun goBack() {}
    open val url: String? get() = null

    open var webViewClient: WebViewClient? = null
    open var webChromeClient: WebChromeClient? = null
    open val settings: WebSettings = WebSettings()
}

fun WebView.post(runnable: Runnable): Boolean = true
fun WebView.post(runnable: () -> Unit): Boolean = true

open class WebSettings {
    open var javaScriptEnabled: Boolean = true
    open var javaScriptCanOpenWindowsAutomatically: Boolean = false
    open var domStorageEnabled: Boolean = true
    open var allowFileAccess: Boolean = true
    open var allowContentAccess: Boolean = true
    open var mediaPlaybackRequiresUserGesture: Boolean = false
    open var userAgentString: String = ""
    open var blockNetworkLoads: Boolean = false
    open var cacheMode: Int = 0
    open var mixedContentMode: Int = 0
    open var databaseEnabled: Boolean = true
    open var builtInZoomControls: Boolean = false
    open var displayZoomControls: Boolean = false

    open fun setSupportZoom(support: Boolean) {}
    open fun setSupportMultipleWindows(support: Boolean) {}

    companion object {
        const val MIXED_CONTENT_NEVER_ALLOW = 1
        const val LOAD_NO_CACHE = 2
        const val LOAD_DEFAULT = -1
    }
}

open class CookieManager {
    companion object {
        private val instance = CookieManager()
        @JvmStatic
        fun getInstance(): CookieManager = instance
    }

    open fun setAcceptCookie(accept: Boolean) {}
    open fun setAcceptThirdPartyCookies(webView: WebView, accept: Boolean) {}
    open fun getCookie(url: String?): String? = null
    open fun setCookie(url: String?, value: String?) {}
    open fun setCookie(url: String?, value: String?, callback: ((Boolean) -> Unit)?) {
        callback?.invoke(true)
    }
    open fun removeSessionCookies(callback: ((Boolean) -> Unit)?) {
        callback?.invoke(true)
    }
    open fun removeAllCookies(callback: ((Boolean) -> Unit)?) {
        callback?.invoke(true)
    }
    open fun flush() {}
}

open class WebStorage {
    companion object {
        private val instance = WebStorage()
        @JvmStatic
        fun getInstance(): WebStorage = instance
    }

    open fun deleteAllData() {}
}

open class WebViewDatabase {
    companion object {
        private val instance = WebViewDatabase()
        @JvmStatic
        fun getInstance(context: Context): WebViewDatabase = instance
    }

    open fun clearHttpAuthUsernamePassword() {}
    open fun clearFormData() {}
    open fun clearUsernamePassword() {}
}

open class RenderProcessGoneDetail {
    open fun didCrash(): Boolean = false
}

open class WebViewClient {
    open fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean = false
    open fun shouldOverrideUrlLoading(view: WebView, url: String?): Boolean = false
    open fun onPageStarted(view: WebView, url: String?, favicon: Bitmap?) {}
    open fun onPageFinished(view: WebView, url: String?) {}
    open fun shouldInterceptRequest(view: WebView, request: WebResourceRequest): WebResourceResponse? = null
    open fun onRenderProcessGone(view: WebView, detail: RenderProcessGoneDetail): Boolean = false
    open fun doUpdateVisitedHistory(view: WebView, url: String?, isReload: Boolean) {}
}

open class WebChromeClient {
    open fun onConsoleMessage(consoleMessage: ConsoleMessage): Boolean = false
    open fun onProgressChanged(view: WebView, newProgress: Int) {}
    open fun onCreateWindow(view: WebView, isDialog: Boolean, isUserGesture: Boolean, resultMsg: Message): Boolean = false
    open fun onCloseWindow(window: WebView) {}
}

open class ConsoleMessage(
    private val messageText: String = "",
    private val sourceIdStr: String = "",
    private val lineNum: Int = 0,
    private val level: MessageLevel = MessageLevel.LOG
) {
    enum class MessageLevel { TIP, LOG, WARNING, ERROR, DEBUG }

    fun message(): String = messageText
    fun messageLevel(): MessageLevel = level
    fun sourceId(): String = sourceIdStr
    fun lineNumber(): Int = lineNum
}

@Target(AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
annotation class JavascriptInterface

open class WebResourceRequest {
    open val url: Uri = Uri.EMPTY
    open val method: String = "GET"
    open val requestHeaders: Map<String, String> = emptyMap()
    open val isForMainFrame: Boolean = true
}

open class WebResourceResponse {
    var mimeType: String? = null
    var encoding: String? = null
    var data: InputStream? = null

    constructor()
    constructor(mimeType: String?, encoding: String?, data: InputStream?) {
        this.mimeType = mimeType
        this.encoding = encoding
        this.data = data
    }
}

open class MimeTypeMap {
    companion object {
        private val instance = MimeTypeMap()
        @JvmStatic
        fun getSingleton(): MimeTypeMap = instance
    }

    open fun getMimeTypeFromExtension(extension: String?): String? = null
    open fun getExtensionFromMimeType(mimeType: String?): String? = null
}
