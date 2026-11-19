package android.icu.text

import java.util.Locale

open class ListFormatter {
    open fun format(vararg items: Any?): String = items.joinToString(", ")

    companion object {
        @JvmStatic
        fun getInstance(locale: Locale?): ListFormatter = ListFormatter()
    }
}
