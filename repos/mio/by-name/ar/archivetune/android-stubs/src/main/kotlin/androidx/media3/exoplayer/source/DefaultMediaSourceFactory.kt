package androidx.media3.exoplayer.source

/*
 * Upstream builds it as DefaultMediaSourceFactory(dataSourceFactory); the parameter list is a
 * vararg so any of media3's overloads type-check.
 */
open class DefaultMediaSourceFactory(
    vararg args: Any?,
) {
    fun setDataSourceFactory(factory: androidx.media3.datasource.DataSource.Factory): DefaultMediaSourceFactory = this

    fun createMediaSource(item: androidx.media3.common.MediaItem): MediaSource = MediaSource()

    companion object { }
}
