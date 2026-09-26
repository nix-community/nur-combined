package androidx.media3.common

open class MediaMetadata {
    open val title: CharSequence? = null
    open val artist: CharSequence? = null
    open val mediaType: Int? = null

    companion object {
        const val MEDIA_TYPE_MIXED = 0
        const val MEDIA_TYPE_MUSIC = 1
        const val MEDIA_TYPE_PODCAST = 2
        const val MEDIA_TYPE_AUDIO_BOOK = 3
        const val MEDIA_TYPE_RADIO_STATION = 4
        const val MEDIA_TYPE_NEWS = 5
        const val MEDIA_TYPE_VIDEO = 6
        const val MEDIA_TYPE_TRAILER = 7
        const val MEDIA_TYPE_MOVIE = 8
        const val MEDIA_TYPE_TV_SHOW = 9
        const val MEDIA_TYPE_ALBUM = 10
        const val MEDIA_TYPE_ARTIST = 11
        const val MEDIA_TYPE_GENRE = 12
        const val MEDIA_TYPE_PLAYLIST = 13
        const val MEDIA_TYPE_YEAR = 14
        const val MEDIA_TYPE_PODCAST_EPISODE = 15
        const val MEDIA_TYPE_TV_CHANNEL = 16
        const val MEDIA_TYPE_TV_SEASON = 17
        const val MEDIA_TYPE_TV_EPISODE = 18
    }

    class Builder {
        fun setTitle(title: CharSequence?): Builder = this
        fun setArtist(artist: CharSequence?): Builder = this
        fun setAlbumTitle(title: CharSequence?): Builder = this
        fun setAlbumArtist(artist: CharSequence?): Builder = this
        fun setDisplayTitle(title: CharSequence?): Builder = this
        fun setSubtitle(subtitle: CharSequence?): Builder = this
        fun setDescription(description: CharSequence?): Builder = this
        fun setArtworkUri(uri: android.net.Uri?): Builder = this
        fun setTrackNumber(trackNumber: Int?): Builder = this
        fun setTotalTrackCount(totalTrackCount: Int?): Builder = this
        fun setFolderType(folderType: Int?): Builder = this
        fun setMediaType(mediaType: Int?): Builder = this
        fun setExtras(extras: android.os.Bundle?): Builder = this
        fun populate(metadata: MediaMetadata?): Builder = this
        fun build(): MediaMetadata = MediaMetadata()
    }
}
