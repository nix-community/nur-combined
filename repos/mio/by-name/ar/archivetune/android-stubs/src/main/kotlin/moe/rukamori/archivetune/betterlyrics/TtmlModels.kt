package moe.rukamori.archivetune.betterlyrics

/*
 * The :lyrics module (and the betterlyrics provider in it) is a git submodule, which
 * fetchFromGitHub does not fetch, so the desktop port declares its data surface here.
 * Types are kept faithful to how the app consumes them; parsing itself is inert.
 */
enum class TtmlTimingMode {
    WORD,
    LINE,
    UNKNOWN,
}

class TtmlTiming(
    val startMs: Long = 0L,
    val endMs: Long = 0L,
)

class TtmlLine(
    val text: String = "",
    val key: String? = null,
    val timing: TtmlTiming = TtmlTiming(),
    val language: String? = null,
    val agent: String? = null,
    val order: Int = 0,
    val sourceOrder: Int = 0,
    val words: List<TtmlLine> = emptyList(),
    val main: TtmlTrack = TtmlTrack(),
    val backgrounds: List<TtmlTrack> = emptyList(),
    val romanizations: List<TtmlTrack> = emptyList(),
    val translations: List<TtmlTrack> = emptyList(),
    val providerRomanizedText: String? = null,
    val providerRomanizedWords: List<TtmlLine>? = null,
    val providerRomanizedLanguage: String? = null,
    val providerTranslationText: String? = null,
) {
    fun normalizedSupplementaryText(): String = text
}

class TtmlTrack(
    val language: String? = null,
    val text: String = "",
    val timingMode: TtmlTimingMode = TtmlTimingMode.LINE,
    val sourceOrder: Int = 0,
    val order: Int = 0,
    val segments: List<TtmlLine> = emptyList(),
    val words: List<TtmlLine> = emptyList(),
) {
    fun normalizedSupplementaryText(): String = text.orEmpty()
}

class TtmlDocument(
    val language: String? = null,
    val timingMode: TtmlTimingMode = TtmlTimingMode.LINE,
    val segments: List<TtmlLine> = emptyList(),
    val lines: List<TtmlLine> = emptyList(),
    val words: List<TtmlLine> = emptyList(),
    val agents: List<TtmlAgent> = emptyList(),
    val main: TtmlTrack = TtmlTrack(),
    val backgrounds: List<TtmlTrack> = emptyList(),
    val romanizations: List<TtmlTrack> = emptyList(),
    val translations: List<TtmlTrack> = emptyList(),
    val sourceOrder: Int = 0,
)
