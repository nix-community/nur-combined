package androidx.core.view

import android.graphics.Bitmap
import android.graphics.Bitmap.Config
import android.view.View

inline fun View.drawToBitmap(config: Config = Config.ARGB_8888): Bitmap = Bitmap()
