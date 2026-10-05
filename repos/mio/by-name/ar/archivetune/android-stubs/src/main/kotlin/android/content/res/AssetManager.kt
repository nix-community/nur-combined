package android.content.res

import java.io.InputStream
import java.io.ByteArrayInputStream

open class AssetManager {
    open fun open(fileName: String): InputStream = ByteArrayInputStream(ByteArray(0))
}
