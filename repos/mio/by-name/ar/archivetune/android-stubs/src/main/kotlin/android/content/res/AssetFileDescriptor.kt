package android.content.res

import java.io.FileDescriptor

open class AssetFileDescriptor {
    val fileDescriptor: FileDescriptor = FileDescriptor()

    val startOffset: Long = 0L

    val length: Long = 0L

    val declaredLength: Long = 0L

    fun createInputStream(): java.io.FileInputStream? = null

    fun createOutputStream(): java.io.FileOutputStream? = null

    fun close() {}
}
