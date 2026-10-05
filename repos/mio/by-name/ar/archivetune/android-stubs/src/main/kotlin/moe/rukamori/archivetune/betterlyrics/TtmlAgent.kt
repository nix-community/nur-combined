package moe.rukamori.archivetune.betterlyrics

open class TtmlAgent {
    var id: String = ""
    var type: TtmlAgentType = TtmlAgentType.OTHER
}

enum class TtmlAgentType {
    GROUP,
    ORGANIZATION,
    OTHER
}
