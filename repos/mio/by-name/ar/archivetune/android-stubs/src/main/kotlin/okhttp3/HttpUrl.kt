package okhttp3
open class HttpUrl {
    open fun queryParameter(name: String): String? = null
    val host: String = ""
    val pathSegments: List<String> = emptyList()
    companion object {
        fun parse(url: String): HttpUrl? = HttpUrl()
        fun String.toHttpUrlOrNull(): HttpUrl? = HttpUrl()
    }
}
