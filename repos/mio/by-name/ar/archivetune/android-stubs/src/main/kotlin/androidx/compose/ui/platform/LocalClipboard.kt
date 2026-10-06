package androidx.compose.ui.platform

import androidx.compose.runtime.CompositionLocal
import androidx.compose.runtime.staticCompositionLocalOf

/*
 * LocalClipboard is a Compose 1.8+ API; compose 1.7.0 ships LocalClipboardManager
 * instead. The port provides the accessor upstream code expects.
 */
interface Clipboard

val LocalClipboard: CompositionLocal<Clipboard> =
    staticCompositionLocalOf { object : Clipboard {} }
