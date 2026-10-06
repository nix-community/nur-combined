package moe.rukamori.archivetune.betterlyrics

class Word(
    val text: String = "",
    val startTime: Double = 0.0,
    val endTime: Double = 0.0,
    val isBackground: Boolean = false
)

class Line(
    val startTime: Double = 0.0,
    val endTime: Double = 0.0,
    val text: String = "",
    val words: List<Word> = emptyList(),
    val agent: String? = null,
    val providerRomanizedText: String? = null,
    val providerRomanizedWords: List<String>? = null,
    val providerRomanizedLanguage: String? = null,
    val providerTranslationText: String? = null
)

object QRCParser {
    fun isQrc(lyrics: String): Boolean = false

    fun hasWordTimings(lyrics: String): Boolean = false

    fun parseQrc(lyrics: String): List<Line> = emptyList()
}

object TTMLParser {
    fun parseTTML(lyrics: String): List<Line> = emptyList()

    // Upstream calls `TTMLParser.parseDocument(source).getOrThrow()`, so the result must be
    // a Result<TtmlDocument>; without it `document` is error-typed and every member access
    // on it cascades into "unresolved reference".
    fun parseDocument(source: String): Result<TtmlDocument> = Result.success(TtmlDocument())

    fun parseDocument(source: String, parseOptions: Any): Result<TtmlDocument> =
        Result.success(TtmlDocument())
}
