package android.graphics.drawable

open class Drawable {
    val intrinsicWidth: Int = 0
    val intrinsicHeight: Int = 0
    open fun setBounds(left: Int, top: Int, right: Int, bottom: Int) {}
    open fun draw(canvas: android.graphics.Canvas) {}
}

fun Drawable.toBitmap(width: Int = intrinsicWidth, height: Int = intrinsicHeight, config: android.graphics.Bitmap.Config? = null): android.graphics.Bitmap = android.graphics.Bitmap()
