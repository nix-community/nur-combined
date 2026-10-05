package me.bush.translator

class Translator {
    fun translateBlocking(text: String, targetLanguage: Any): Translation = Translation(text)
}
class Translation(val translatedText: String)
enum class Language {
    ENGLISH, SPANISH, FRENCH, GERMAN, CHINESE, JAPANESE, KOREAN, RUSSIAN, PORTUGUESE, ITALIAN
}
