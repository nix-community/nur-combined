package android.graphics

import java.io.OutputStream

open class Bitmap {
    open val width: Int = 0
    open val height: Int = 0
    open val config: Config = Config.ARGB_8888
    open val isRecycled: Boolean = false

    open fun compress(format: CompressFormat, quality: Int, stream: OutputStream): Boolean = true
    open fun copy(config: Config, isMutable: Boolean): Bitmap = Bitmap()

    open fun recycle() {}
    open fun getPixels(pixels: IntArray, offset: Int, stride: Int, x: Int, y: Int, width: Int, height: Int) {}
    open fun setPixels(pixels: IntArray, offset: Int, stride: Int, x: Int, y: Int, width: Int, height: Int) {}

    enum class CompressFormat {
        JPEG, PNG, WEBP, WEBP_LOSSY, WEBP_LOSSLESS
    }

    enum class Config {
        ALPHA_8, RGB_565, ARGB_4444, ARGB_8888, RGBA_F16, HARDWARE
    }

    companion object {
        fun createBitmap(width: Int, height: Int, config: Config): Bitmap = Bitmap()
        fun createBitmap(source: Bitmap, x: Int, y: Int, width: Int, height: Int): Bitmap = Bitmap()
        fun createScaledBitmap(src: Bitmap, dstWidth: Int, dstHeight: Int, filter: Boolean): Bitmap = Bitmap()
        fun createBitmap(
            source: Bitmap,
            x: Int,
            y: Int,
            width: Int,
            height: Int,
            m: android.graphics.Matrix?,
            filter: Boolean,
        ): Bitmap = Bitmap()
    }
}
