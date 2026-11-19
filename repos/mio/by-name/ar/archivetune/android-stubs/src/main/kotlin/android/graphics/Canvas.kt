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
    open fun drawRect(left: Float, top: Float, right: Float, bottom: Float, paint: Paint) {}
    open fun drawRect(left: Int, top: Int, right: Int, bottom: Int, paint: Paint) {}
    open fun drawRoundRect(
        left: Float,
        top: Float,
        right: Float,
        bottom: Float,
        rx: Float,
        ry: Float,
        paint: Paint
    ) {}
    open fun drawLine(startX: Float, startY: Float, stopX: Float, stopY: Float, paint: Paint) {}
    open fun drawPath(path: Path, paint: Paint) {}
    open fun drawArc(
        oval: android.graphics.RectF,
        startAngle: Float,
        sweepAngle: Float,
        useCenter: Boolean,
        paint: Paint
    ) {}
    open fun clipRect(left: Float, top: Float, right: Float, bottom: Float): Boolean = true
    open fun clipPath(path: Path): Boolean = true
    open fun saveLayer(bounds: android.graphics.RectF?, paint: Paint?): Int = 0
    open fun scale(sx: Float, sy: Float) {}
    open fun rotate(degrees: Float) {}
    open fun concat(matrix: Matrix?) {}
}
