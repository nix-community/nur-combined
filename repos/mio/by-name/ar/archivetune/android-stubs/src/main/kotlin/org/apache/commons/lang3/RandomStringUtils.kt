package org.apache.commons.lang3

import java.security.SecureRandom

/*
 * Real generator for the IDs upstream derives from Apache Commons:
 * ArtistEntity.generateArtistId(), PlaylistEntity.generatePlaylistId() and
 * TagEntity.generateTagId() call `RandomStringUtils.insecure().next(8, ...)`.
 * Returning "" made every generated entity share the same id ("LA", "LP",
 * "TAG"), so creating a second local playlist/tag/artist collided with the
 * first instead of producing a distinct row.
 */
open class RandomStringUtils {
    fun next(count: Int, letters: Boolean, numbers: Boolean): String {
        val alphabet =
            buildString {
                if (letters) append(Alphabetic)
                if (numbers) append(Numeric)
            }
        if (alphabet.isEmpty() || count <= 0) return ""
        return buildString(count) {
            repeat(count) { append(alphabet[random.nextInt(alphabet.length)]) }
        }
    }

    fun next(count: Int, chars: String): String {
        if (chars.isEmpty() || count <= 0) return ""
        return buildString(count) {
            repeat(count) { append(chars[random.nextInt(chars.length)]) }
        }
    }

    fun randomAlphanumeric(count: Int): String = next(count, letters = true, numbers = true)

    companion object {
        private const val Alphabetic = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        private const val Numeric = "0123456789"
        private val random = SecureRandom()

        fun insecure(): RandomStringUtils = RandomStringUtils()

        fun randomAlphanumeric(count: Int): String =
            RandomStringUtils().next(count, letters = true, numbers = true)

        fun randomAlphabetic(count: Int): String =
            RandomStringUtils().next(count, letters = true, numbers = false)

        fun randomNumeric(count: Int): String =
            RandomStringUtils().next(count, letters = false, numbers = true)
    }
}
