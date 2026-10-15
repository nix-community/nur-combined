package android.graphics.drawable

import android.content.Context
import android.content.res.Resources
import android.graphics.Bitmap

open class BitmapDrawable : Drawable {
    val bitmap: Bitmap?

    constructor() : super() {
        this.bitmap = null
    }

    constructor(bitmap: Bitmap?) : super() {
        this.bitmap = bitmap
    }

    constructor(res: Resources?, bitmap: Bitmap?) : super() {
        this.bitmap = bitmap
    }
}

open class Icon {
    companion object {
        fun createWithResource(context: Context, resId: Int): Icon = Icon()
        fun createWithResource(resPackage: String, resId: Int): Icon = Icon()
        fun createWithBitmap(bitmap: Bitmap): Icon = Icon()
    }
}
