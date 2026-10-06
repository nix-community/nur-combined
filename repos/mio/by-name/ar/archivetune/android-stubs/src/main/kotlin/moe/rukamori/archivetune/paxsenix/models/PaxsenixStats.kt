package moe.rukamori.archivetune.paxsenix.models

/*
 * Provided by the :lyrics:paxsenix submodule (not fetched by fetchFromGitHub).
 * PaxsenixStatsState.Success carries a PaxsenixStats, and the lyrics settings screen
 * reads the dashboard fields directly off it, so they live here as well as on
 * ProviderStats.
 */
class PaxsenixStats(
    val users: Int = 0,
    val songs: Int = 0,
    val overallSuccessRate: String = "0%",
    val uptimeSeconds: Double = 0.0,
    val totalRequests: Long = 0L,
    val success: Long = 0L,
    val failure: Long = 0L,
    val providers: Map<String, ProviderStats> = emptyMap(),
    val hits: Long = 0L,
    val requestLog: List<ProviderRequestLogEntry> = emptyList(),
    val stats: ProviderStats = ProviderStats(),
    val isHealthy: Boolean = true,
    val error: String? = null,
)
