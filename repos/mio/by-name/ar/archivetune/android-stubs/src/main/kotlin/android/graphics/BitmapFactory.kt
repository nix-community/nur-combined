package android.graphics

object BitmapFactory {
    fun decodeFileDescriptor(fd: java.io.FileDescriptor, outPadding: Rect?, opts: Options?): Bitmap? = Bitmap()
    fun decodeFile(pathName: String?, opts: Options? = null): Bitmap? = Bitmap()
    fun decodeStream(inputStream: java.io.InputStream?, outPadding: Rect? = null, opts: Options? = null): Bitmap? = Bitmap()
    fun decodeResource(res: Any?, id: Int, opts: Options? = null): Bitmap? = Bitmap()
    fun decodeByteArray(data: ByteArray, offset: Int, length: Int, opts: Options? = null): Bitmap? = Bitmap()
    
    class Options {
        var inJustDecodeBounds: Boolean = false
        var outWidth: Int = 0
        var outHeight: Int = 0
        var inSampleSize: Int = 1
        var inPreferredConfig: Bitmap.Config? = null
    }
}
