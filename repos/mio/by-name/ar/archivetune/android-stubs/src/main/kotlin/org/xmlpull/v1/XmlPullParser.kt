package org.xmlpull.v1

import java.io.InputStream
import java.io.Reader

interface XmlPullParser {
    companion object {
        const val START_DOCUMENT = 0
        const val END_DOCUMENT = 1
        const val START_TAG = 2
        const val END_TAG = 3
        const val TEXT = 4
    }

    fun setInput(reader: Reader)
    fun setInput(inputStream: InputStream, inputEncoding: String?)
    val eventType: Int
    val name: String?
    val text: String?
    fun next(): Int
    fun nextText(): String
    fun getAttributeValue(namespace: String?, name: String): String?
}
