package android.net

import java.io.ByteArrayOutputStream
import java.io.File

/*
 * Real (if minimal) Uri implementation.
 *
 * The previous stub returned "" / null / empty lists from every accessor, so
 * Uri.parse(url), Uri.fromFile(file) and the Builder all produced an empty Uri.
 * Callers that hand a Uri to the image loader (PlayerComponents) or store the
 * string form of a cached canvas file (CanvasArtworkPlaybackCache) therefore
 * saw an empty model/path. Scheme, authority, path, query and fragment are
 * parsed and rendered, with Android-style percent encoding for encode/decode.
 */
open class Uri(
    val scheme: String? = null,
    val encodedAuthority: String? = null,
    val encodedPath: String = "",
    val encodedQuery: String? = null,
    val encodedFragment: String? = null,
) {
    val authority: String? get() = encodedAuthority?.let(::decode)

    private val hostAndPort: Pair<String?, Int>
        get() {
            val auth = encodedAuthority ?: return null to -1
            val hostPart = auth.substringAfterLast('@')
            val colon = hostPart.lastIndexOf(':')
            if (colon <= 0) return hostPart to -1
            return hostPart.substring(0, colon) to (hostPart.substring(colon + 1).toIntOrNull() ?: -1)
        }

    val host: String? get() = hostAndPort.first

    val port: Int get() = hostAndPort.second

    val path: String get() = decode(encodedPath)

    val pathSegments: List<String> get() = path.split('/').filter(String::isNotEmpty)

    val lastPathSegment: String? get() = pathSegments.lastOrNull()

    val query: String? get() = encodedQuery?.let(::decode)

    val fragment: String? get() = encodedFragment?.let(::decode)

    val encodedUserInfo: String? get() = encodedAuthority?.substringBeforeLast('@', "")?.takeIf(String::isNotEmpty)

    val queryParameterNames: Set<String>
        get() =
            encodedQuery
                ?.split('&')
                ?.filter(String::isNotEmpty)
                ?.map { decode(it.substringBefore('=')) }
                ?.toSet()
                .orEmpty()

    fun getQueryParameter(key: String): String? = getQueryParameters(key).firstOrNull()

    fun getQueryParameters(key: String): List<String> =
        encodedQuery
            ?.split('&')
            ?.filter(String::isNotEmpty)
            ?.mapNotNull { parameter ->
                val name = decode(parameter.substringBefore('='))
                if (name != key) return@mapNotNull null
                if (!parameter.contains('=')) "" else decode(parameter.substringAfter('='))
            }
            .orEmpty()

    fun buildUpon(): Builder = Builder(this)

    override fun toString(): String =
        buildString {
            scheme?.let { append(it).append(':') }
            encodedAuthority?.let { append("//").append(it) }
            append(encodedPath)
            encodedQuery?.let { append('?').append(it) }
            encodedFragment?.let { append('#').append(it) }
        }

    override fun equals(other: Any?): Boolean = other is Uri && other.toString() == toString()

    override fun hashCode(): Int = toString().hashCode()

    class Builder internal constructor(uri: Uri?) {
        private var scheme: String? = uri?.scheme
        private var authority: String? = uri?.encodedAuthority
        private var path: String = uri?.encodedPath ?: ""
        private var query: String? = uri?.encodedQuery
        private var fragment: String? = uri?.encodedFragment

        constructor() : this(null)

        fun scheme(scheme: String): Builder = apply { this.scheme = scheme }

        fun authority(authority: String): Builder = apply { this.authority = authority }

        fun path(path: String): Builder = apply { this.path = path }

        fun appendPath(pathSegment: String): Builder =
            apply {
                path =
                    when {
                        path.isEmpty() -> "/$pathSegment"
                        path.endsWith("/") -> path + pathSegment
                        else -> "$path/$pathSegment"
                    }
            }

        fun appendQueryParameter(key: String, value: String): Builder =
            apply {
                val pair = "${Uri.encode(key)}=${Uri.encode(value)}"
                query = if (query.isNullOrEmpty()) pair else "$query&$pair"
            }

        fun clearQuery(): Builder = apply { query = null }

        fun build(): Uri = Uri(scheme, authority, path, query, fragment)
    }

    companion object {
        private const val Hex = "0123456789ABCDEF"

        val EMPTY: Uri = Uri()

        @JvmStatic
        fun parse(uriString: String): Uri {
            var rest = uriString
            var fragment: String? = null
            val hash = rest.indexOf('#')
            if (hash >= 0) {
                fragment = rest.substring(hash + 1)
                rest = rest.substring(0, hash)
            }
            var query: String? = null
            val questionMark = rest.indexOf('?')
            if (questionMark >= 0) {
                query = rest.substring(questionMark + 1)
                rest = rest.substring(0, questionMark)
            }
            var scheme: String? = null
            val colon = rest.indexOf(':')
            if (colon > 0 && rest.substring(0, colon).matches(Regex("[A-Za-z][A-Za-z0-9+.-]*"))) {
                scheme = rest.substring(0, colon).lowercase()
                rest = rest.substring(colon + 1)
            }
            var authority: String? = null
            if (rest.startsWith("//")) {
                rest = rest.removePrefix("//")
                val slash = rest.indexOf('/')
                authority = if (slash >= 0) rest.substring(0, slash) else rest
                rest = if (slash >= 0) rest.substring(slash) else ""
            }
            return Uri(scheme, authority, rest, query, fragment)
        }

        @JvmStatic
        fun fromParts(scheme: String, ssp: String, fragment: String?): Uri =
            Uri(scheme = scheme, encodedPath = ssp, encodedFragment = fragment)

        @JvmStatic
        fun fromFile(file: java.io.File): Uri =
            Builder().scheme("file").path(file.absolutePath).build()

        /** Percent-encodes everything outside the RFC 3986 unreserved set (UTF-8). */
        @JvmStatic
        fun encode(s: String): String =
            buildString {
                for (byte in s.toByteArray(Charsets.UTF_8)) {
                    val code = byte.toInt() and 0xFF
                    val ch = code.toChar()
                    if ((code < 128 && (ch.isLetterOrDigit() || ch in "-._~"))) {
                        append(ch)
                    } else {
                        append('%').append(Hex[code ushr 4]).append(Hex[code and 0x0F])
                    }
                }
            }

        @JvmStatic
        fun decode(s: String): String {
            val out = ByteArrayOutputStream()
            var i = 0
            while (i < s.length) {
                val ch = s[i]
                if (ch == '%' && i + 2 < s.length) {
                    val value = s.substring(i + 1, i + 3).toIntOrNull(16)
                    if (value != null) {
                        out.write(value)
                        i += 3
                        continue
                    }
                }
                out.write(ch.toString().toByteArray(Charsets.UTF_8))
                i++
            }
            return out.toString(Charsets.UTF_8.name())
        }
    }
}
