package okio

class ByteString {
    fun base64(): String = ""
    fun toByteArray(): ByteArray = ByteArray(0)
    
    companion object {
        fun ByteArray.toByteString(): ByteString = ByteString()
        fun String.decodeBase64(): ByteString? = ByteString()
    }
}
