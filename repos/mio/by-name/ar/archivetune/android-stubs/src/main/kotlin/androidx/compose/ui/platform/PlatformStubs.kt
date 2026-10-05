package androidx.compose.ui.platform

import android.content.res.Configuration
import android.view.View
import androidx.compose.runtime.compositionLocalOf

val LocalView = compositionLocalOf<View> { View() }
val LocalConfiguration = compositionLocalOf<Configuration> { Configuration() }
