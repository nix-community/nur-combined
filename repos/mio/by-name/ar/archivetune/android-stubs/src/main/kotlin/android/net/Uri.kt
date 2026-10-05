package android.net

open class Uri {
    override fun toString(): String = ""
    open val path: String? = null
    open val scheme: String? = null
    open val host: String? = null
    open val lastPathSegment: String? = null
    open val authority: String? = null
    open fun buildUpon(): Builder = Builder()

    class Builder {
        fun scheme(scheme: String): Builder = this
        fun authority(authority: String): Builder = this
        fun path(path: String): Builder = this
        fun appendPath(pathSegment: String): Builder = this
        fun appendQueryParameter(key: String, value: String): Builder = this
        fun build(): Uri = Uri()
    }

    companion object {
        @JvmStatic fun parse(uriString: String): Uri = Uri()
        @JvmStatic fun fromFile(file: java.io.File): Uri = Uri()
        @JvmStatic fun encode(s: String): String = s
        @JvmStatic fun decode(s: String): String = s
        val EMPTY: Uri = Uri()
    }
}
