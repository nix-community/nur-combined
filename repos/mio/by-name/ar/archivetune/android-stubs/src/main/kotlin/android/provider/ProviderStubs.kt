package android.provider

import android.content.ContentResolver
import android.net.Uri

object DocumentsContract {
    fun buildDocumentUriUsingTree(treeUri: Uri, documentId: String): Uri = treeUri
    fun buildChildDocumentsUriUsingTree(treeUri: Uri, parentDocumentId: String): Uri = treeUri
    fun buildTreeDocumentUri(authority: String, documentId: String): Uri =
        Uri.parse("content://$authority/tree/$documentId")
    fun getTreeDocumentId(documentUri: Uri): String = ""
    fun getDocumentId(documentUri: Uri): String = ""
    fun isDocumentUri(context: android.content.Context?, uri: Uri?): Boolean = false
    fun createDocument(contentResolver: ContentResolver, parentDocumentUri: Uri, mimeType: String, displayName: String): Uri? = parentDocumentUri

    object Document {
        const val COLUMN_DISPLAY_NAME = "_display_name"
        const val COLUMN_DOCUMENT_ID = "document_id"
        const val COLUMN_MIME_TYPE = "mime_type"
    }
}

object OpenableColumns {
    const val DISPLAY_NAME = "_display_name"
    const val SIZE = "_size"
}

object Settings {
    const val ACTION_APPLICATION_DETAILS_SETTINGS = "android.settings.APPLICATION_DETAILS_SETTINGS"
    const val ACTION_APP_OPEN_BY_DEFAULT_SETTINGS = "android.settings.APP_OPEN_BY_DEFAULT_SETTINGS"
    const val ACTION_BLUETOOTH_SETTINGS = "android.settings.BLUETOOTH_SETTINGS"
    const val ACTION_MANAGE_UNKNOWN_APP_SOURCES = "android.settings.MANAGE_UNKNOWN_APP_SOURCES"
    const val ACTION_APP_NOTIFICATION_SETTINGS = "android.settings.APP_NOTIFICATION_SETTINGS"
    const val EXTRA_APP_PACKAGE = "android.provider.extra.APP_PACKAGE"

    object System {
        val CONTENT_URI: Uri = Uri.parse("content://settings/system")
        fun getInt(resolver: ContentResolver, name: String, def: Int): Int = def
        fun getString(resolver: ContentResolver, name: String): String? = null
        fun putInt(resolver: ContentResolver, name: String, value: Int): Boolean = true
        fun putString(resolver: ContentResolver, name: String, value: String?): Boolean = true
    }

    object Secure {
        val CONTENT_URI: Uri = Uri.parse("content://settings/secure")
        fun getInt(resolver: ContentResolver, name: String, def: Int): Int = def
        fun getString(resolver: ContentResolver, name: String): String? = null
    }

    object Global {
        val CONTENT_URI: Uri = Uri.parse("content://settings/global")
        fun getInt(resolver: ContentResolver, name: String, def: Int): Int = def
        fun getString(resolver: ContentResolver, name: String): String? = null
    }
}
