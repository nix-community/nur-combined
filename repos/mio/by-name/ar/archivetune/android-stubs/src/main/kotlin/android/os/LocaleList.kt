package android.os

import java.util.Locale

/* Minimal LocaleList; upstream reads configuration.locales.get(0). */
open class LocaleList(vararg locales: Locale) {
    private val values: List<Locale> = locales.toList()

    val size: Int get() = values.size

    operator fun get(index: Int): Locale = values.getOrElse(index) { Locale.ENGLISH }

    fun isEmpty(): Boolean = values.isEmpty()

    override fun toString(): String = values.joinToString(",") { it.toString() }

    companion object {
        val EMPTY: LocaleList = LocaleList()

        @JvmStatic
        fun forLanguageTags(list: String?): LocaleList = LocaleList()

        @JvmStatic
        fun getDefault(): LocaleList = LocaleList(Locale.ENGLISH)
    }
}
