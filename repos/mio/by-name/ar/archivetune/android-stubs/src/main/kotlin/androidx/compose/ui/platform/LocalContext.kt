package androidx.compose.ui.platform

import android.content.Context
import androidx.compose.runtime.compositionLocalOf

val LocalContext = compositionLocalOf<Context> { androidx.hilt.navigation.compose._createViewModelInstance(Context::class.java) as Context }
