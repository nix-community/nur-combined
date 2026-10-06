package android.content

import android.net.Uri
import java.io.InputStream
import java.io.OutputStream

open class ContentResolver {
    open fun insert(uri: Uri, values: Any?): Uri? = null
    open fun query(
        uri: Uri,
        projection: Array<String>?,
        selection: String?,
        selectionArgs: Array<String>?,
        sortOrder: String?
    ): android.database.Cursor? = null
    open fun delete(uri: Uri, selection: String?, selectionArgs: Array<String>?): Int = 0
    open fun update(uri: Uri, values: Any?, selection: String?, selectionArgs: Array<String>?): Int = 0
    open fun openInputStream(uri: Uri): InputStream? = null
    open fun openOutputStream(uri: Uri): OutputStream? = null
    open fun openOutputStream(uri: Uri, mode: String): OutputStream? = null
    open fun openFileDescriptor(uri: Uri, mode: String): android.os.ParcelFileDescriptor? = null
    open fun takePersistableUriPermission(uri: Uri, flags: Int) {}
    open fun releasePersistableUriPermission(uri: Uri, flags: Int) {}
    /* Persisted-permission bookkeeping used by the background customisation screen. */
    open val persistedUriPermissions: List<UriPermission> get() = emptyList()
    open fun getType(uri: Uri): String? = null
    open fun registerContentObserver(uri: Uri, notifyForDescendants: Boolean, observer: Any?) {}
    open fun unregisterContentObserver(observer: Any?) {}
    open fun call(uri: Uri, method: String, arg: String?, extras: android.os.Bundle?): android.os.Bundle? = null
    open fun notifyChange(uri: Uri, observer: Any?) {}
}
