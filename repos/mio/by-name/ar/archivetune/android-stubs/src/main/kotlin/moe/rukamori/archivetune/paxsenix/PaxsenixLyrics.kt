package moe.rukamori.archivetune.paxsenix

import moe.rukamori.archivetune.paxsenix.models.PaxsenixStats

object PaxsenixLyrics {
    suspend fun getStats(): Result<PaxsenixStats> = Result.success(PaxsenixStats())
    fun setUserAgent(appName: String, version: String) {}
    fun setApiKey(apiKey: String) {}
}
