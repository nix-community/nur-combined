package android.graphics

open class Canvas {
    constructor()
    constructor(bitmap: Bitmap)
    open val width: Int = 0
    open val height: Int = 0
    open fun drawColor(color: Int) {}
    open fun drawCircle(cx: Float, cy: Float, radius: Float, paint: Paint) {}
    open fun drawBitmap(bitmap: Bitmap, left: Float, top: Float, paint: Paint?) {}
    open fun drawBitmap(bitmap: Bitmap, src: android.graphics.Rect?, dst: android.graphics.RectF, paint: Paint?) {}
    open fun drawText(text: String, x: Float, y: Float, paint: Paint) {}
    open fun save(): Int = 0
    open fun translate(dx: Float, dy: Float) {}
    open fun restoreToCount(saveCount: Int) {}
    open fun drawRoundRect(rect: android.graphics.RectF, rx: Float, ry: Float, paint: Paint) {}
    open fun drawRect(rect: android.graphics.RectF, paint: Paint) {}
}
