package androidx.compose.ui.hapticfeedback

import androidx.compose.runtime.compositionLocalOf

open class HapticFeedback {
    open fun performHapticFeedback(hapticFeedbackType: HapticFeedbackType) {}
}

enum class HapticFeedbackType {
    LongPress, TextHandleMove, Confirm, Reject, ToggleOn, ToggleOff,
    GestureStart, GestureEnd, VirtualKey, VirtualKeyRelease
}

val LocalHapticFeedback = compositionLocalOf<HapticFeedback> { HapticFeedback() }
