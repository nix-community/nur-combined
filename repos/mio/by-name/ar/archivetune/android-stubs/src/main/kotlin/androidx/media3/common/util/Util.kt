package androidx.media3.common.util

/* media3's Util helpers; upstream decodes download request data with fromUtf8Bytes. */
object Util {
    @JvmStatic
    fun fromUtf8Bytes(bytes: ByteArray): String = String(bytes, Charsets.UTF_8)

    @JvmStatic
    fun getUtf8Bytes(value: String): ByteArray = value.toByteArray(Charsets.UTF_8)

    @JvmStatic
    fun getBytesFromHexString(hexString: String): ByteArray = ByteArray(0)

    @JvmStatic
    fun getHexString(bytes: ByteArray): String = ""

    @JvmStatic
    fun inferContentType(uri: android.net.Uri?): Int = 0

    @JvmStatic
    fun toByteArray(inputStream: java.io.InputStream): ByteArray = ByteArray(0)

    @JvmStatic
    fun getStringForTime(formatter: Any?, timeMs: Long): String = ""
}
