package moe.rukamori.archivetune.betterlyrics

open class TtmlAgent {
    var id: String = ""
    var type: TtmlAgentType = TtmlAgentType.OTHER
    var order: Int = 0
    var name: String = ""
}

enum class TtmlAgentType {
    GROUP,
    ORGANIZATION,
    OTHER
}
