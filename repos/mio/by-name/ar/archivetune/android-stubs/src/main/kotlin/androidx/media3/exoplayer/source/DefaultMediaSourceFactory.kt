package androidx.media3.exoplayer.source

/*
 * Upstream builds it as DefaultMediaSourceFactory(dataSourceFactory); the parameter list is a
 * vararg so any of media3's overloads type-check.
 */
open class DefaultMediaSourceFactory(
    vararg args: Any?,
) {
    companion object { }
}
