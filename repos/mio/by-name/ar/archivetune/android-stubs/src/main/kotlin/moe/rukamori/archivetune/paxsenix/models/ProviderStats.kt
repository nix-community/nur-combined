package moe.rukamori.archivetune.paxsenix.models

/*
 * Provided by the :lyrics:paxsenix submodule (not fetched by fetchFromGitHub). The lyrics
 * settings screen renders `state.stats` (a PaxsenixStats) and its provider rows take a
 * ProviderStats, so `providers` maps names to ProviderStats - not to a separate entry type.
 */
data class ProviderStats(
    val name: String = "",
    val overallSuccessRate: String = "0%",
    val successRate: String = "0%",
    val uptimeSeconds: Double = 0.0,
    val totalRequests: Long = 0L,
    val success: Long = 0L,
    val failure: Long = 0L,
    val averageResponseMs: Long = 0L,
    val hits: Long = 0L,
    val endpoint: String = "",
    val providers: Map<String, ProviderStats> = emptyMap(),
    val requestLog: List<ProviderRequestLogEntry> = emptyList(),
)

data class ProviderStatsEntry(
    val name: String = "",
    val successRate: String = "0%",
    val success: Long = 0L,
    val failure: Long = 0L,
    val endpoint: String = "",
    val averageResponseMs: Long = 0L,
)

data class ProviderRequestLogEntry(
    val timestamp: Long = 0L,
    val endpoint: String = "",
    val provider: String = "",
    val success: Boolean = false,
    val durationMs: Long = 0L,
    val responseTimeMs: Long = 0L,
    val errorMessage: String? = null,
)
