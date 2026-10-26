package android.content

import java.awt.Toolkit
import java.awt.datatransfer.StringSelection

open class ClipboardManager {
    private var _clip: ClipData? = null

    open fun setPrimaryClip(clip: ClipData) {
        _clip = clip
        val text = clip.item.text?.toString()
        if (!text.isNullOrBlank()) {
            try {
                val selection = StringSelection(text)
                Toolkit.getDefaultToolkit().systemClipboard.setContents(selection, selection)
            } catch (t: Throwable) {
                System.err.println("[ArchiveTune/Clipboard] Failed to set system clipboard: ${t.message}")
            }
        }
    }

    open val primaryClip: ClipData? get() = _clip
}
