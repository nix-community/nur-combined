package android.provider

import android.net.Uri

object MediaStore {
    object MediaColumns {
        const val DISPLAY_NAME = "DISPLAY_NAME"
        const val MIME_TYPE = "MIME_TYPE"
        const val RELATIVE_PATH = "RELATIVE_PATH"
    }

    object Images {
        object Media {
            val EXTERNAL_CONTENT_URI = Uri.parse("")
        }
    }

    object Audio {
        object Media {
            const val _ID = "_id"
            const val TITLE = "title"
            const val DISPLAY_NAME = "display_name"
            const val ARTIST = "artist"
            const val ARTIST_ID = "artist_id"
            const val ALBUM = "album"
            const val ALBUM_ID = "album_id"
            const val ALBUM_ARTIST = "album_artist"
            const val DURATION = "duration"
            const val YEAR = "year"
            const val TRACK = "track"
            const val DATE_ADDED = "date_added"
            const val DATE_MODIFIED = "date_modified"
            const val SIZE = "_size"
            const val MIME_TYPE = "mime_type"
            const val IS_MUSIC = "is_music"
            val EXTERNAL_CONTENT_URI = Uri.parse("")
        }
    }
}
