package androidx.activity.compose

import android.app.Activity
import androidx.compose.runtime.staticCompositionLocalOf

/** Desktop has no Activity; a bare instance keeps `LocalActivity.current` non-null. */
val LocalActivity = staticCompositionLocalOf<Activity> { Activity() }
