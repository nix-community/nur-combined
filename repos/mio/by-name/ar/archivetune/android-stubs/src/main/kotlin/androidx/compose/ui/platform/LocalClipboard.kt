package androidx.compose.ui.platform

import androidx.compose.runtime.CompositionLocal
import androidx.compose.runtime.staticCompositionLocalOf

/*
 * LocalClipboard is a Compose 1.8+ API; compose 1.7.0 ships LocalClipboardManager
 * instead. The port provides the accessor upstream code expects.
 */
interface Clipboard {
    suspend fun setClipEntry(clipEntry: ClipEntry?)
    suspend fun getClipEntry(): ClipEntry?
}

/**
 * Android-only wrapper upstream builds out of a [android.content.ClipData]; desktop has no
 * equivalent, so the port keeps the type and drops the payload.
 */
class ClipEntry(val clipData: android.content.ClipData? = null)

val LocalClipboard: CompositionLocal<Clipboard> =
    staticCompositionLocalOf {
        object : Clipboard {
            override suspend fun setClipEntry(clipEntry: ClipEntry?) {}
            override suspend fun getClipEntry(): ClipEntry? = null
        }
    }
