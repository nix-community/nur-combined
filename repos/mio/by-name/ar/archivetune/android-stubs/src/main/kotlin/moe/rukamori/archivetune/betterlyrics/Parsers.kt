package moe.rukamori.archivetune.betterlyrics

class Word(
    val text: String = "",
    val startTime: Double = 0.0,
    val endTime: Double = 0.0,
    val isBackground: Boolean = false
)

class Line(
    val startTime: Double = 0.0,
    val text: String = "",
    val words: List<Word> = emptyList(),
    val agent: String? = null,
    val providerRomanizedText: String? = null,
    val providerRomanizedWords: List<Word>? = null,
    val providerRomanizedLanguage: String? = null,
    val providerTranslationText: String? = null
)

object QRCParser {
    fun isQrc(lyrics: String): Boolean = false
    fun parseQrc(lyrics: String): List<Line> = emptyList()
}

object TTMLParser {
    fun parseTTML(lyrics: String): List<Line> = emptyList()
}
