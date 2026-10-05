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
}
