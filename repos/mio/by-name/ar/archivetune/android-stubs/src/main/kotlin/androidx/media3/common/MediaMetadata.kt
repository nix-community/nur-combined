package androidx.media3.common

open class MediaMetadata {
    open val id: String? = null
    open val mediaId: String? = null
    open val title: CharSequence? = null
    open val artist: CharSequence? = null
    open val album: CharSequence? = null
    open val albumArtist: CharSequence? = null
    open val albumTitle: CharSequence? = null
    open val displayTitle: CharSequence? = null
    open val subtitle: CharSequence? = null
    open val description: CharSequence? = null
    open val artworkUri: android.net.Uri? = null
    open val thumbnailUrl: CharSequence? = null
    open val duration: Long? = null
    open val trackNumber: Int? = null
    open val totalTrackCount: Int? = null
    open val folderType: Int? = null
    open val isBrowsable: Boolean = false
    open val isPlayable: Boolean = false
    open val isAdvertisement: Boolean = false
    open val extras: android.os.Bundle? = null
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

        const val FOLDER_TYPE_NONE = 0
        const val FOLDER_TYPE_MIXED = 1
        const val FOLDER_TYPE_TITLES = 2
        const val FOLDER_TYPE_ALBUMS = 3
        const val FOLDER_TYPE_ARTISTS = 4
        const val FOLDER_TYPE_GENRES = 5
        const val FOLDER_TYPE_PLAYLISTS = 6
        const val FOLDER_TYPE_YEARS = 7

        // Aliases the app refers to when building browse trees.
        const val MEDIA_TYPE_FOLDER_MIXED = FOLDER_TYPE_MIXED
        const val MEDIA_TYPE_FOLDER_ALBUMS = FOLDER_TYPE_ALBUMS
        const val MEDIA_TYPE_FOLDER_ARTISTS = FOLDER_TYPE_ARTISTS
        const val MEDIA_TYPE_FOLDER_GENRES = FOLDER_TYPE_GENRES
        const val MEDIA_TYPE_FOLDER_PLAYLISTS = FOLDER_TYPE_PLAYLISTS
        const val MEDIA_TYPE_FOLDER_YEARS = FOLDER_TYPE_YEARS
    }

    class Builder {
        fun setId(id: String?): Builder = this
        fun setMediaId(mediaId: String?): Builder = this
        fun setTitle(title: CharSequence?): Builder = this
        fun setArtist(artist: CharSequence?): Builder = this
        fun setAlbumTitle(title: CharSequence?): Builder = this
        fun setAlbumArtist(artist: CharSequence?): Builder = this
        fun setDisplayTitle(title: CharSequence?): Builder = this
        fun setSubtitle(subtitle: CharSequence?): Builder = this
        fun setDescription(description: CharSequence?): Builder = this
        fun setArtworkUri(uri: android.net.Uri?): Builder = this
        fun setArtworkData(data: ByteArray?, pictureType: Int = 0): Builder = this
        fun setTrackNumber(trackNumber: Int?): Builder = this
        fun setReleaseYear(releaseYear: Int?): Builder = this
        fun setDiscNumber(discNumber: Int?): Builder = this
        fun setTotalDiscCount(totalDiscCount: Int?): Builder = this
        fun setTotalTrackCount(totalTrackCount: Int?): Builder = this
        fun setFolderType(folderType: Int?): Builder = this
        fun setIsBrowsable(isBrowsable: Boolean): Builder = this
        fun setIsPlayable(isPlayable: Boolean): Builder = this
        fun setMediaType(mediaType: Int?): Builder = this
        fun setExtras(extras: android.os.Bundle?): Builder = this
        fun populate(metadata: MediaMetadata?): Builder = this
        fun build(): MediaMetadata = MediaMetadata()
    }
}
