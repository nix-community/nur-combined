package androidx.webkit

import android.net.Uri
import android.webkit.WebView
import android.webkit.CookieManager

class Profile {
    val cookieManager: CookieManager = CookieManager.getInstance()
}

class WebMessageCompat {
    val data: String? = null
}

class JavaScriptReplyProxy

fun interface WebMessageListener {
    fun onPostMessage(view: WebView, message: WebMessageCompat, sourceOrigin: Uri, isMainFrame: Boolean, replyProxy: JavaScriptReplyProxy)
}

object WebViewCompat {
    fun addWebMessageListener(webView: WebView, jsObjectName: String, allowedOriginRules: Set<String>, listener: WebMessageListener) {}
    fun getProfile(webView: WebView): Profile = Profile()
    fun setProfile(webView: WebView, profileName: String) {}
}
