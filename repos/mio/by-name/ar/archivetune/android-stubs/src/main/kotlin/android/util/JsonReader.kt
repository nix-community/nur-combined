package android.util

import java.io.Closeable
import java.io.IOException
import java.io.Reader

enum class JsonToken {
    BEGIN_ARRAY,
    END_ARRAY,
    BEGIN_OBJECT,
    END_OBJECT,
    NAME,
    STRING,
    NUMBER,
    BOOLEAN,
    NULL,
    END_DOCUMENT,
}

/**
 * Minimal streaming JSON reader for the desktop port (Android's lives in the
 * platform). Only the operations the :modules manifest reader uses are
 * implemented; the tokenizer is strict enough to reject truncated documents.
 */
class JsonReader(private val input: Reader) : Closeable {
    private val text = input.readText()
    private var pos = 0
    private val stack = ArrayDeque<Char>()
    private var expectName = false

    var isLenient: Boolean = true

    private fun skipWhitespace() {
        while (pos < text.length && text[pos].isWhitespace()) pos++
    }

    private fun fail(message: String): Nothing =
        throw IOException("$message at offset $pos")

    fun peek(): JsonToken {
        while (true) {
            skipWhitespace()
            if (pos >= text.length) return JsonToken.END_DOCUMENT
            when (text[pos]) {
                ',' -> {
                    pos++
                    if (stack.lastOrNull() == '{') expectName = true
                }
                ':' -> pos++
                '{' -> return JsonToken.BEGIN_OBJECT
                '}' -> return JsonToken.END_OBJECT
                '[' -> return JsonToken.BEGIN_ARRAY
                ']' -> return JsonToken.END_ARRAY
                '"' -> return if (expectName && stack.lastOrNull() == '{') JsonToken.NAME else JsonToken.STRING
                't', 'f' -> return JsonToken.BOOLEAN
                'n' -> return JsonToken.NULL
                else -> return JsonToken.NUMBER
            }
        }
    }

    fun beginObject() {
        skipWhitespace()
        if (pos >= text.length || text[pos] != '{') fail("expected '{'")
        pos++
        stack.addLast('{')
        expectName = true
    }

    fun endObject() {
        skipWhitespace()
        if (pos >= text.length || text[pos] != '}') fail("expected '}'")
        pos++
        if (stack.removeLastOrNull() != '{') fail("unbalanced object")
        expectName = false
    }

    fun beginArray() {
        skipWhitespace()
        if (pos >= text.length || text[pos] != '[') fail("expected '['")
        pos++
        stack.addLast('[')
        expectName = false
    }

    fun endArray() {
        skipWhitespace()
        if (pos >= text.length || text[pos] != ']') fail("expected ']'")
        pos++
        if (stack.removeLastOrNull() != '[') fail("unbalanced array")
        expectName = false
    }

    fun hasNext(): Boolean = when (peek()) {
        JsonToken.END_OBJECT, JsonToken.END_ARRAY, JsonToken.END_DOCUMENT -> false
        else -> true
    }

    private fun nextQuoted(): String {
        skipWhitespace()
        if (pos >= text.length || text[pos] != '"') fail("expected string")
        pos++
        val out = StringBuilder()
        while (pos < text.length) {
            when (val c = text[pos++]) {
                '"' -> return out.toString()
                '\\' -> {
                    if (pos >= text.length) fail("unterminated escape")
                    when (val e = text[pos++]) {
                        '"', '\\', '/' -> out.append(e)
                        'b' -> out.append('\b')
                        'f' -> out.append('\u000C')
                        'n' -> out.append('\n')
                        'r' -> out.append('\r')
                        't' -> out.append('\t')
                        'u' -> {
                            if (pos + 4 > text.length) fail("unterminated unicode escape")
                            out.append(text.substring(pos, pos + 4).toInt(16).toChar())
                            pos += 4
                        }
                        else -> fail("invalid escape '$e'")
                    }
                }
                else -> out.append(c)
            }
        }
        fail("unterminated string")
    }

    fun nextName(): String {
        val name = nextQuoted()
        expectName = false
        return name
    }

    private fun nextLiteral(): String {
        skipWhitespace()
        val start = pos
        while (pos < text.length && !text[pos].isWhitespace() && text[pos] !in ",}]") pos++
        if (start == pos) fail("expected value")
        return text.substring(start, pos)
    }

    fun nextString(): String = when (peek()) {
        JsonToken.STRING, JsonToken.NAME -> nextQuoted()
        JsonToken.NUMBER -> nextLiteral()
        else -> fail("expected string")
    }

    fun nextInt(): Int = nextString().toInt()
    fun nextLong(): Long = nextString().toLong()
    fun nextDouble(): Double = nextString().toDouble()

    fun nextBoolean(): Boolean {
        val value = nextLiteral()
        return when (value) {
            "true" -> true
            "false" -> false
            else -> fail("expected boolean")
        }
    }

    fun nextNull() {
        if (nextLiteral() != "null") fail("expected null")
    }

    fun skipValue() {
        when (peek()) {
            JsonToken.BEGIN_OBJECT -> {
                beginObject()
                while (hasNext()) {
                    nextName()
                    skipValue()
                }
                endObject()
            }
            JsonToken.BEGIN_ARRAY -> {
                beginArray()
                while (hasNext()) skipValue()
                endArray()
            }
            JsonToken.STRING, JsonToken.NUMBER -> nextString()
            JsonToken.BOOLEAN -> nextBoolean()
            JsonToken.NULL -> nextNull()
            else -> fail("expected value")
        }
    }

    override fun close() = input.close()
}
