package org.xmlpull.v1

import java.io.OutputStream
import java.io.Writer

interface XmlSerializer {
    fun setOutput(os: OutputStream, encoding: String?)
    fun setOutput(writer: Writer)
    fun startDocument(encoding: String?, standalone: Boolean?)
    fun endDocument()
    fun startTag(namespace: String?, name: String): XmlSerializer
    fun endTag(namespace: String?, name: String): XmlSerializer
    fun attribute(namespace: String?, name: String, value: String): XmlSerializer
    fun text(text: String): XmlSerializer
    fun flush()
}
