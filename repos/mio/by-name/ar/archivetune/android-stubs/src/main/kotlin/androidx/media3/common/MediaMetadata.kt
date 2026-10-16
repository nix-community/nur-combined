package androidx.media3.common

open class MediaMetadata(
    open val id: String? = null,
    open val mediaId: String? = null,
    open val title: CharSequence? = null,
    open val artist: CharSequence? = null,
    open val album: CharSequence? = null,
    open val albumArtist: CharSequence? = null,
    open val albumTitle: CharSequence? = null,
    open val displayTitle: CharSequence? = null,
    open val subtitle: CharSequence? = null,
    open val description: CharSequence? = null,
    open val artworkUri: android.net.Uri? = null,
    open val thumbnailUrl: CharSequence? = null,
    open val duration: Long? = null,
    open val trackNumber: Int? = null,
    open val totalTrackCount: Int? = null,
    open val folderType: Int? = null,
    open val isBrowsable: Boolean = false,
    open val isPlayable: Boolean = false,
    open val isAdvertisement: Boolean = false,
    open val extras: android.os.Bundle? = null,
    open val mediaType: Int? = null,
) {
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
        private var id: String? = null
        private var mediaId: String? = null
        private var title: CharSequence? = null
        private var artist: CharSequence? = null
        private var album: CharSequence? = null
        private var albumArtist: CharSequence? = null
        private var albumTitle: CharSequence? = null
        private var displayTitle: CharSequence? = null
        private var subtitle: CharSequence? = null
        private var description: CharSequence? = null
        private var artworkUri: android.net.Uri? = null
        private var thumbnailUrl: CharSequence? = null
        private var duration: Long? = null
        private var trackNumber: Int? = null
        private var totalTrackCount: Int? = null
        private var folderType: Int? = null
        private var isBrowsable: Boolean = false
        private var isPlayable: Boolean = false
        private var isAdvertisement: Boolean = false
        private var extras: android.os.Bundle? = null
        private var mediaType: Int? = null

        fun setId(id: String?): Builder = apply { this.id = id }
        fun setMediaId(mediaId: String?): Builder = apply { this.mediaId = mediaId }
        fun setTitle(title: CharSequence?): Builder = apply { this.title = title }
        fun setArtist(artist: CharSequence?): Builder = apply { this.artist = artist }
        fun setAlbumTitle(title: CharSequence?): Builder = apply { this.albumTitle = title }
        fun setAlbumArtist(artist: CharSequence?): Builder = apply { this.albumArtist = artist }
        fun setDisplayTitle(title: CharSequence?): Builder = apply { this.displayTitle = title }
        fun setSubtitle(subtitle: CharSequence?): Builder = apply { this.subtitle = subtitle }
        fun setDescription(description: CharSequence?): Builder = apply { this.description = description }
        fun setArtworkUri(uri: android.net.Uri?): Builder = apply { this.artworkUri = uri }
        fun setArtworkData(data: ByteArray?, pictureType: Int = 0): Builder = this
        fun setTrackNumber(trackNumber: Int?): Builder = apply { this.trackNumber = trackNumber }
        fun setReleaseYear(releaseYear: Int?): Builder = this
        fun setDiscNumber(discNumber: Int?): Builder = this
        fun setTotalDiscCount(totalDiscCount: Int?): Builder = this
        fun setTotalTrackCount(totalTrackCount: Int?): Builder = apply { this.totalTrackCount = totalTrackCount }
        fun setFolderType(folderType: Int?): Builder = apply { this.folderType = folderType }
        fun setIsBrowsable(isBrowsable: Boolean): Builder = apply { this.isBrowsable = isBrowsable }
        fun setIsPlayable(isPlayable: Boolean): Builder = apply { this.isPlayable = isPlayable }
        fun setMediaType(mediaType: Int?): Builder = apply { this.mediaType = mediaType }
        fun setExtras(extras: android.os.Bundle?): Builder = apply { this.extras = extras }
        fun populate(metadata: MediaMetadata?): Builder = apply {
            if (metadata != null) {
                this.id = metadata.id
                this.mediaId = metadata.mediaId
                this.title = metadata.title
                this.artist = metadata.artist
                this.album = metadata.album
                this.albumArtist = metadata.albumArtist
                this.albumTitle = metadata.albumTitle
                this.displayTitle = metadata.displayTitle
                this.subtitle = metadata.subtitle
                this.description = metadata.description
                this.artworkUri = metadata.artworkUri
                this.thumbnailUrl = metadata.thumbnailUrl
                this.duration = metadata.duration
                this.trackNumber = metadata.trackNumber
                this.totalTrackCount = metadata.totalTrackCount
                this.folderType = metadata.folderType
                this.isBrowsable = metadata.isBrowsable
                this.isPlayable = metadata.isPlayable
                this.isAdvertisement = metadata.isAdvertisement
                this.extras = metadata.extras
                this.mediaType = metadata.mediaType
            }
        }
        fun build(): MediaMetadata = MediaMetadata(
            id = id,
            mediaId = mediaId,
            title = title,
            artist = artist,
            album = album,
            albumArtist = albumArtist,
            albumTitle = albumTitle,
            displayTitle = displayTitle,
            subtitle = subtitle,
            description = description,
            artworkUri = artworkUri,
            thumbnailUrl = thumbnailUrl,
            duration = duration,
            trackNumber = trackNumber,
            totalTrackCount = totalTrackCount,
            folderType = folderType,
            isBrowsable = isBrowsable,
            isPlayable = isPlayable,
            isAdvertisement = isAdvertisement,
            extras = extras,
            mediaType = mediaType,
        )
    }
}
