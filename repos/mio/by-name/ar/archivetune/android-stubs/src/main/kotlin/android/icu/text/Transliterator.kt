package android.icu.text

open class Transliterator {
    companion object {
        private val instance = Transliterator()
        @JvmStatic
        fun getInstance(id: String): Transliterator = instance
    }

    open fun transliterate(text: String): String = text
}
