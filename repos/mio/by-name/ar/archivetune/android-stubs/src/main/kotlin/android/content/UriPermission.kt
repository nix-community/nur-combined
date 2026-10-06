package android.content

/*
 * One persisted content-URI grant; the background customisation screen inspects its uri and
 * read/write flags.
 */
open class UriPermission(
    val uri: android.net.Uri = android.net.Uri.EMPTY,
    val isReadPermission: Boolean = true,
    val isWritePermission: Boolean = false,
    val persistedTime: Long = 0L,
)
