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

open class Paint(flags: Int = 0) {
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
    var textAlign: Align = Align.LEFT
    var letterSpacing: Float = 0f
    var textScaleX: Float = 1f

    enum class Align { LEFT, CENTER, RIGHT }

    companion object {
        const val ANTI_ALIAS_FLAG = 1
        const val FILTER_BITMAP_FLAG = 2
    }

    fun setShadowLayer(radius: Float, dx: Float, dy: Float, shadowColor: Int) {}
    fun clearShadowLayer() {}
    fun getFontMetrics(metrics: FontMetrics) {}
    fun getFontMetricsInt(metrics: FontMetricsInt) {}

    class FontMetrics {
        var ascent: Float = 0f
        var descent: Float = 0f
        var top: Float = 0f
        var bottom: Float = 0f
        var leading: Float = 0f
    }

    class FontMetricsInt {
        var ascent: Int = 0
        var descent: Int = 0
        var top: Int = 0
        var bottom: Int = 0
        var leading: Int = 0
    }

    fun measureText(text: String): Float = text.length * textSize * 0.6f
    fun measureText(text: CharSequence, start: Int, end: Int): Float = (end - start) * textSize * 0.6f
    fun getTextBounds(text: String, start: Int, end: Int, bounds: Rect) {
        bounds.left = 0
        bounds.top = 0
        bounds.right = (measureText(text.substring(start, end))).toInt()
        bounds.bottom = textSize.toInt()
    }
}

object PorterDuff {
    enum class Mode { CLEAR, SRC, DST, SRC_OVER, DST_OVER, SRC_IN, DST_IN, SRC_OUT, DST_OUT, SRC_ATOP, DST_ATOP, XOR, DARKEN, LIGHTEN, MULTIPLY, SCREEN, ADD, OVERLAY }
}

open class Shader {
    enum class TileMode { CLAMP, REPEAT, MIRROR, DECAL }
}

class LinearGradient(
    x0: Float,
    y0: Float,
    x1: Float,
    y1: Float,
    colors: IntArray,
    positions: FloatArray? = null,
    tileMode: Shader.TileMode = Shader.TileMode.CLAMP,
) : Shader() {
    constructor(
        x0: Float,
        y0: Float,
        x1: Float,
        y1: Float,
        color0: Int,
        color1: Int,
        tileMode: Shader.TileMode = Shader.TileMode.CLAMP,
    ) : this(x0, y0, x1, y1, intArrayOf(color0, color1), null, tileMode)
}

class RadialGradient(
    centerX: Float,
    centerY: Float,
    radius: Float,
    colors: IntArray,
    positions: FloatArray? = null,
    tileMode: Shader.TileMode = Shader.TileMode.CLAMP,
) : Shader() {
    constructor(
        centerX: Float,
        centerY: Float,
        radius: Float,
        color0: Int,
        color1: Int,
        tileMode: Shader.TileMode = Shader.TileMode.CLAMP,
    ) : this(centerX, centerY, radius, intArrayOf(color0, color1), null, tileMode)
}

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
    fun addOval(rect: RectF, dir: Direction) {}
    fun arcTo(rect: RectF, startAngle: Float, sweepAngle: Float) {}
    fun close() {}
}
