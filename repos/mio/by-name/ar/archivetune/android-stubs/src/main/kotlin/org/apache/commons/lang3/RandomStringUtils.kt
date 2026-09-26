package org.apache.commons.lang3

open class RandomStringUtils {
    fun next(count: Int, letters: Boolean, numbers: Boolean): String = ""
    fun randomAlphanumeric(count: Int): String = ""
    fun next(count: Int, chars: String): String = ""

    companion object {
        fun insecure(): RandomStringUtils = RandomStringUtils()
        fun randomAlphanumeric(count: Int): String = ""
        fun randomAlphabetic(count: Int): String = ""
        fun randomNumeric(count: Int): String = ""
    }
}
