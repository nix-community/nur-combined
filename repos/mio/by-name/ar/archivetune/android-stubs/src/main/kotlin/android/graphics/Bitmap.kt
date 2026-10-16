package android.graphics

import java.awt.RenderingHints
import java.awt.image.BufferedImage
import java.io.OutputStream
import javax.imageio.ImageIO
import androidx.compose.ui.graphics.ImageBitmap

open class Bitmap(
    var bufferedImage: BufferedImage? = null,
    var imageBitmap: ImageBitmap? = null,
) {
    open val width: Int get() = bufferedImage?.width ?: imageBitmap?.width ?: 0
    open val height: Int get() = bufferedImage?.height ?: imageBitmap?.height ?: 0
    open val config: Config = Config.ARGB_8888
    open var isRecycled: Boolean = false

    open fun compress(format: CompressFormat, quality: Int, stream: OutputStream): Boolean {
        val img = bufferedImage ?: return false
        val formatName = when (format) {
            CompressFormat.PNG -> "png"
            CompressFormat.JPEG -> "jpeg"
            else -> "png"
        }
        return try {
            ImageIO.write(img, formatName, stream)
        } catch (_: Exception) {
            false
        }
    }

    open fun copy(config: Config, isMutable: Boolean): Bitmap {
        val img = bufferedImage ?: return Bitmap()
        val copyImg = BufferedImage(img.width, img.height, BufferedImage.TYPE_INT_ARGB)
        val g = copyImg.createGraphics()
        g.drawImage(img, 0, 0, null)
        g.dispose()
        return Bitmap(bufferedImage = copyImg, imageBitmap = imageBitmap)
    }

    open fun recycle() {
        isRecycled = true
    }

    open fun getPixels(pixels: IntArray, offset: Int, stride: Int, x: Int, y: Int, width: Int, height: Int) {
        val img = bufferedImage ?: return
        try {
            img.getRGB(x, y, width, height, pixels, offset, stride)
        } catch (_: Exception) {}
    }

    open fun setPixels(pixels: IntArray, offset: Int, stride: Int, x: Int, y: Int, width: Int, height: Int) {
        val img = bufferedImage ?: return
        try {
            img.setRGB(x, y, width, height, pixels, offset, stride)
        } catch (_: Exception) {}
    }

    enum class CompressFormat {
        JPEG, PNG, WEBP, WEBP_LOSSY, WEBP_LOSSLESS
    }

    enum class Config {
        ALPHA_8, RGB_565, ARGB_4444, ARGB_8888, RGBA_F16, HARDWARE
    }

    companion object {
        fun createBitmap(width: Int, height: Int, config: Config): Bitmap {
            val w = width.coerceAtLeast(1)
            val h = height.coerceAtLeast(1)
            val img = BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB)
            return Bitmap(bufferedImage = img)
        }

        fun createBitmap(source: Bitmap, x: Int, y: Int, width: Int, height: Int): Bitmap {
            val srcImg = source.bufferedImage ?: return Bitmap()
            val sub = srcImg.getSubimage(x, y, width, height)
            val copyImg = BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB)
            val g = copyImg.createGraphics()
            g.drawImage(sub, 0, 0, null)
            g.dispose()
            return Bitmap(bufferedImage = copyImg)
        }

        fun createScaledBitmap(src: Bitmap, dstWidth: Int, dstHeight: Int, filter: Boolean): Bitmap {
            val srcImg = src.bufferedImage ?: return Bitmap()
            val w = dstWidth.coerceAtLeast(1)
            val h = dstHeight.coerceAtLeast(1)
            val scaled = BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB)
            val g = scaled.createGraphics()
            if (filter) {
                g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR)
                g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY)
                g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON)
            }
            g.drawImage(srcImg, 0, 0, w, h, null)
            g.dispose()
            return Bitmap(bufferedImage = scaled)
        }

        fun createBitmap(
            source: Bitmap,
            x: Int,
            y: Int,
            width: Int,
            height: Int,
            m: android.graphics.Matrix?,
            filter: Boolean,
        ): Bitmap = createBitmap(source, x, y, width, height)
    }
}
