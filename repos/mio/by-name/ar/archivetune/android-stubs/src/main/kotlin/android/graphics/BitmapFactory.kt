package android.graphics

object BitmapFactory {
    fun decodeFileDescriptor(fd: java.io.FileDescriptor, outPadding: Rect?, opts: Options?): Bitmap? = Bitmap()
    fun decodeByteArray(data: ByteArray, offset: Int, length: Int, opts: Options? = null): Bitmap? = Bitmap()
    
    class Options {
        var inJustDecodeBounds: Boolean = false
        var outWidth: Int = 0
        var outHeight: Int = 0
        var inSampleSize: Int = 1
        var inPreferredConfig: Bitmap.Config? = null
    }
}
