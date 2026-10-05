package android.content
open class ClipboardManager {
    open fun setPrimaryClip(clip: ClipData) {}
    open val primaryClip: ClipData? = null
}
