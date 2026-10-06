package androidx.core.content.res

import android.content.Context
import android.graphics.Typeface

/* androidx.core's ResourcesCompat; upstream loads a bundled font through getFont. */
object ResourcesCompat {
    @JvmStatic
    fun getFont(context: Context?, id: Int): Typeface? = null

    @JvmStatic
    fun getFont(context: Context?, id: Int, style: Any?): Typeface? = null
}
