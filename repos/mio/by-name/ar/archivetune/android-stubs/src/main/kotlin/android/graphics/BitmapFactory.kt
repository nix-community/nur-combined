package android.graphics

import androidx.compose.ui.graphics.toComposeImageBitmap
import java.io.ByteArrayInputStream
import java.io.File
import java.io.FileInputStream
import java.io.InputStream
import javax.imageio.ImageIO

object BitmapFactory {
    fun decodeFileDescriptor(fd: java.io.FileDescriptor, outPadding: Rect? = null, opts: Options? = null): Bitmap? {
        return try {
            val fis = FileInputStream(fd)
            decodeStream(fis, outPadding, opts)
        } catch (_: Exception) {
            null
        }
    }

    fun decodeFile(pathName: String?, opts: Options? = null): Bitmap? {
        if (pathName == null) return null
        return try {
            val file = File(pathName)
            if (!file.exists()) return null
            val bytes = file.readBytes()
            decodeByteArray(bytes, 0, bytes.size, opts)
        } catch (_: Exception) {
            null
        }
    }

    fun decodeStream(inputStream: InputStream?, outPadding: Rect? = null, opts: Options? = null): Bitmap? {
        if (inputStream == null) return null
        return try {
            val bytes = inputStream.readBytes()
            decodeByteArray(bytes, 0, bytes.size, opts)
        } catch (_: Exception) {
            null
        }
    }

    fun decodeResource(res: Any?, id: Int, opts: Options? = null): Bitmap? = null

    fun decodeByteArray(data: ByteArray, offset: Int, length: Int, opts: Options? = null): Bitmap? {
        if (data.isEmpty() || length <= 0) return null
        return try {
            val bytes = if (offset == 0 && length == data.size) data else data.copyOfRange(offset, offset + length)
            val bais = ByteArrayInputStream(bytes)
            val img = ImageIO.read(bais)
            if (img != null && opts != null) {
                opts.outWidth = img.width
                opts.outHeight = img.height
            }
            if (opts?.inJustDecodeBounds == true) {
                return null
            }
            val skia = try { org.jetbrains.skia.Image.makeFromEncoded(bytes) } catch (_: Throwable) { null }
            val ib = skia?.toComposeImageBitmap() ?: img?.toComposeImageBitmap()
            Bitmap(bufferedImage = img, imageBitmap = ib)
        } catch (_: Exception) {
            null
        }
    }

    class Options {
        var inJustDecodeBounds: Boolean = false
        var outWidth: Int = 0
        var outHeight: Int = 0
        var inSampleSize: Int = 1
        var inPreferredConfig: Bitmap.Config? = null
    }
}
