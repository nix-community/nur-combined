/*
 * ArchiveTune (2026)
 * © Rukamori — github.com/rukamori
 * GPL-3.0 License | Contributors: see git history
 * Do not remove or alter this notice. - Per GPL-3.0 Section 4 & Section 5
 */

package moe.rukamori.archivetune.utils

data class GitCommit(
    val sha: String,
    val message: String,
    val author: String,
    val date: String,
    val url: String,
    val authorAvatarUrl: String? = null,
)

data class ReleaseInfo(
    val tagName: String,
    val name: String,
    val body: String?,
    val publishedAt: String,
    val htmlUrl: String,
    val downloadUrl: String? = null,
)

object Updater {
    var lastCheckTime = -1L

    internal fun isSameVersion(a: String, b: String): Boolean = a.trim() == b.trim()
    internal fun isUpdateAvailable(latestVersion: String, currentVersion: String): Boolean = false
    internal fun findLatestRelease(releases: List<ReleaseInfo>): ReleaseInfo? = releases.firstOrNull()
    internal fun findLatestCanaryRelease(releases: List<ReleaseInfo>): ReleaseInfo? = releases.firstOrNull()
    internal fun getReleaseVersionName(release: ReleaseInfo): String = release.tagName

    suspend fun getCachedReleases(): List<ReleaseInfo> = emptyList()
    suspend fun getLatestVersionName(): Result<String> = Result.failure(IllegalStateException("Updater is disabled"))
    suspend fun getLatestReleaseNotes(): Result<String?> = Result.failure(IllegalStateException("Updater is disabled"))
    suspend fun getLatestReleaseInfo(forceRefresh: Boolean = false): Result<ReleaseInfo> =
        Result.failure(IllegalStateException("Updater is disabled"))
    suspend fun getCommitHistory(page: Int = 1, perPage: Int = 15): Result<List<GitCommit>> =
        Result.success(emptyList())
    fun getLatestDownloadUrl(): String = ""
    suspend fun getLatestCanaryVersionName(): Result<String> = Result.failure(IllegalStateException("Updater is disabled"))
    suspend fun getLatestCanaryReleaseNotes(): Result<String?> = Result.failure(IllegalStateException("Updater is disabled"))
    suspend fun getLatestArtifactReleaseInfo(forceRefresh: Boolean = false): Result<ReleaseInfo> =
        Result.failure(IllegalStateException("Updater is disabled"))
    suspend fun getCachedArtifactReleases(): List<ReleaseInfo> = emptyList()
    suspend fun getAllArtifactReleases(forceRefresh: Boolean = false): Result<List<ReleaseInfo>> =
        Result.success(emptyList())
    fun getLatestCanaryDownloadUrl(): String = ""
    suspend fun getAllReleases(forceRefresh: Boolean = false): Result<List<ReleaseInfo>> =
        Result.success(emptyList())
}
