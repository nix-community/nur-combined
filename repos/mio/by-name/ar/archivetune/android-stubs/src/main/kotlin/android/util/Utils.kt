package android.util

import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

class AtomicFile(val baseFile: File) {
    fun openRead(): FileInputStream = FileInputStream(baseFile)
    fun readFully(): ByteArray = if (baseFile.exists()) baseFile.readBytes() else ByteArray(0)
    fun startWrite(): FileOutputStream {
        baseFile.parentFile?.mkdirs()
        return FileOutputStream(baseFile)
    }
    fun finishWrite(str: FileOutputStream?) {
        str?.flush()
        str?.close()
    }
    fun failWrite(str: FileOutputStream?) {
        str?.close()
    }
    fun delete() {
        baseFile.delete()
    }
    fun exists(): Boolean = baseFile.exists()
}

object Base64 {
    const val DEFAULT = 0
    const val NO_PADDING = 1
    const val NO_WRAP = 2
    const val CRLF = 4
    const val URL_SAFE = 8

    @JvmStatic
    fun encodeToString(input: ByteArray, flags: Int): String =
        java.util.Base64.getEncoder().encodeToString(input)

    @JvmStatic
    fun decode(str: String, flags: Int): ByteArray = try {
        java.util.Base64.getDecoder().decode(str)
    } catch (e: Exception) {
        ByteArray(0)
    }

    @JvmStatic
    fun decode(input: ByteArray, flags: Int): ByteArray = try {
        java.util.Base64.getDecoder().decode(input)
    } catch (e: Exception) {
        ByteArray(0)
    }
}

object Log {
    const val VERBOSE = 2
    const val DEBUG = 3
    const val INFO = 4
    const val WARN = 5
    const val ERROR = 6
    const val ASSERT = 7

    @JvmStatic fun d(tag: String?, msg: String?): Int = 0
    @JvmStatic fun d(tag: String?, msg: String?, tr: Throwable?): Int = 0
    @JvmStatic fun e(tag: String?, msg: String?): Int = 0
    @JvmStatic fun e(tag: String?, msg: String?, tr: Throwable?): Int = 0
    @JvmStatic fun w(tag: String?, msg: String?): Int = 0
    @JvmStatic fun w(tag: String?, msg: String?, tr: Throwable?): Int = 0
    @JvmStatic fun i(tag: String?, msg: String?): Int = 0
    @JvmStatic fun i(tag: String?, msg: String?, tr: Throwable?): Int = 0
    @JvmStatic fun v(tag: String?, msg: String?): Int = 0
    @JvmStatic fun v(tag: String?, msg: String?, tr: Throwable?): Int = 0
}

open class LruCache<K, V>(val maxSize: Int) {
    private val map = LinkedHashMap<K, V>(maxSize, 0.75f, true)

    @Synchronized
    open fun get(key: K): V? = map[key]

    @Synchronized
    open fun put(key: K, value: V): V? {
        val prev = map.put(key, value)
        if (map.size > maxSize) {
            val eldest = map.keys.iterator().next()
            map.remove(eldest)
        }
        return prev
    }

    @Synchronized
    open fun remove(key: K): V? = map.remove(key)

    @Synchronized
    open fun evictAll() {
        map.clear()
    }

    open fun sizeOf(key: K, value: V): Int = 1
    open fun entryRemoved(evicted: Boolean, key: K, oldValue: V, newValue: V?) {}
    open fun create(key: K): V? = null
}

class TypedValue {
    var data: Int = 0
    var resourceId: Int = 0
    var string: CharSequence? = null
    var type: Int = 0

    companion object {
        const val COMPLEX_UNIT_DIP = 1
        const val COMPLEX_UNIT_SP = 2
        const val COMPLEX_UNIT_PT = 3
        const val COMPLEX_UNIT_IN = 4
        const val COMPLEX_UNIT_MM = 5
        @JvmStatic
        fun applyDimension(unit: Int, value: Float, metrics: DisplayMetrics?): Float = value
    }
}

object Xml {
    @JvmStatic
    fun newPullParser(): org.xmlpull.v1.XmlPullParser = object : org.xmlpull.v1.XmlPullParser {
        override fun setInput(reader: java.io.Reader) {}
        override fun setInput(inputStream: java.io.InputStream, inputEncoding: String?) {}
        override val eventType: Int get() = org.xmlpull.v1.XmlPullParser.END_DOCUMENT
        override val name: String? get() = null
        override val text: String? get() = null
        override fun next(): Int = org.xmlpull.v1.XmlPullParser.END_DOCUMENT
        override fun nextText(): String = ""
        override fun getAttributeValue(namespace: String?, name: String): String? = null
    }

    @JvmStatic
    fun newSerializer(): org.xmlpull.v1.XmlSerializer = object : org.xmlpull.v1.XmlSerializer {
        override fun setOutput(os: java.io.OutputStream, encoding: String?) {}
        override fun setOutput(writer: java.io.Writer) {}
        override fun startDocument(encoding: String?, standalone: Boolean?) {}
        override fun endDocument() {}
        override fun startTag(namespace: String?, name: String): org.xmlpull.v1.XmlSerializer = this
        override fun endTag(namespace: String?, name: String): org.xmlpull.v1.XmlSerializer = this
        override fun attribute(namespace: String?, name: String, value: String): org.xmlpull.v1.XmlSerializer = this
        override fun text(text: String): org.xmlpull.v1.XmlSerializer = this
        override fun flush() {}
    }
}
