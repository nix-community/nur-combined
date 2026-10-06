package me.bush.translator

class Translator {
    fun translateBlocking(text: String, targetLanguage: Any): Translation = Translation(text)
}

class Translation(val translatedText: String)

/*
 * The real me.bush.translator Language is a class constructed with a language tag
 * (`Language(tag, strict = true)`), not an enum - an enum cannot be instantiated with arguments,
 * which made upstream's resolveLanguageCode fail to compile.
 */
class Language(
    language: String,
    strict: Boolean = false,
    concurrent: Boolean = false,
) {
    val code: String = language.trim().uppercase()

    override fun toString(): String = code

    companion object {
        val ENGLISH = Language("ENGLISH")
        val SPANISH = Language("SPANISH")
        val FRENCH = Language("FRENCH")
        val GERMAN = Language("GERMAN")
        val CHINESE = Language("CHINESE")
        val JAPANESE = Language("JAPANESE")
        val KOREAN = Language("KOREAN")
        val RUSSIAN = Language("RUSSIAN")
        val PORTUGUESE = Language("PORTUGUESE")
        val ITALIAN = Language("ITALIAN")
    }
}
