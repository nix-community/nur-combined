package android.graphics

open class Matrix {
    fun reset() {}
    fun set(src: Matrix) {}
    fun setScale(sx: Float, sy: Float) {}
    fun setScale(sx: Float, sy: Float, px: Float, py: Float) {}
    fun postScale(sx: Float, sy: Float) {}
    fun postScale(sx: Float, sy: Float, px: Float, py: Float) {}
    fun postTranslate(dx: Float, dy: Float) {}
    fun postRotate(degrees: Float) {}
    fun postRotate(degrees: Float, px: Float, py: Float) {}
    fun postConcat(other: Matrix) {}
    fun preConcat(other: Matrix) {}
    fun mapRect(dst: RectF, src: RectF): Boolean = true
    fun mapRect(rect: RectF): Boolean = true
    fun invert(inverse: Matrix): Boolean = true
    fun getValues(values: FloatArray) {}
    fun setValues(values: FloatArray) {}
}

open class RectF(
    var left: Float = 0f,
    var top: Float = 0f,
    var right: Float = 0f,
    var bottom: Float = 0f
) {
    fun width(): Float = right - left
    fun height(): Float = bottom - top
    fun centerX(): Float = (left + right) * 0.5f
    fun centerY(): Float = (top + bottom) * 0.5f
    fun set(left: Float, top: Float, right: Float, bottom: Float) {
        this.left = left
        this.top = top
        this.right = right
        this.bottom = bottom
    }
}

open class Point(var x: Int = 0, var y: Int = 0)
open class PointF(var x: Float = 0f, var y: Float = 0f)

open class Paint {
    var color: Int = 0
    var isAntiAlias: Boolean = true
    var isDither: Boolean = false
    var isFilterBitmap: Boolean = false
    var textSize: Float = 12f
    var style: Style = Style.FILL
    var strokeWidth: Float = 1f
    var shader: Shader? = null
    var typeface: Typeface? = null
    var alpha: Int = 255

    enum class Style { FILL, STROKE, FILL_AND_STROKE }

    fun measureText(text: String): Float = text.length * textSize * 0.6f
    fun measureText(text: CharSequence, start: Int, end: Int): Float = (end - start) * textSize * 0.6f
    fun getTextBounds(text: String, start: Int, end: Int, bounds: Rect) {
        bounds.left = 0
        bounds.top = 0
        bounds.right = (measureText(text.substring(start, end))).toInt()
        bounds.bottom = textSize.toInt()
    }
}

open class Shader

open class SurfaceTexture(var texName: Int = 0) {
    fun release() {}
    fun setDefaultBufferSize(width: Int, height: Int) {}
    fun updateTexImage() {}
    fun getTransformMatrix(mtx: FloatArray) {}
}

open class Path {
    enum class Direction { CCW, CW }
    fun reset() {}
    fun moveTo(x: Float, y: Float) {}
    fun lineTo(x: Float, y: Float) {}
    fun quadTo(x1: Float, y1: Float, x2: Float, y2: Float) {}
    fun cubicTo(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {}
    fun addRect(left: Float, top: Float, right: Float, bottom: Float, dir: Direction) {}
    fun addRoundRect(rect: RectF, rx: Float, ry: Float, dir: Direction) {}
    fun close() {}
}
