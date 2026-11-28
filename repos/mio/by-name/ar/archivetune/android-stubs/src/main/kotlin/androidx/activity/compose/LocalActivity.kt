package androidx.activity.compose

import android.app.Activity
import androidx.compose.runtime.staticCompositionLocalOf

/** Desktop has no Activity; keep a placeholder for APIs that require one. */
val LocalActivity = staticCompositionLocalOf<Activity?> { Activity() }
