/*
 * ArchiveTune (2026)
 * © Rukamori — github.com/rukamori
 * GPL-3.0 License | Contributors: see git history
 * Do not remove or alter this notice. - Per GPL-3.0 Section 4 & Section 5
 *
 * Desktop-port stand-in for the upstream `:morideobfuscator` Android library
 * (rukamori/morideobfuscator). The real resolver drives a QuickJS worker
 * (com.dokar.quickjs) to run YouTube's signature-deciphering JavaScript; QuickJS
 * ships a native library and the module is an Android library, so the port keeps
 * the resolver's public surface but never resolves anything.
 *
 * The data/model surface is vendored verbatim (YoutubeiModels.kt) so call sites get
 * the real types.
 */
package moe.rukamori.archivetune.morideobfuscator.youtubei

import android.content.Context

class YoutubeiResolver(
    context: Context,
    diagnostics: (String) -> Unit,
    networkConfigurationProvider: () -> YoutubeiNetworkConfiguration,
) {
    constructor(
        context: Context,
        networkConfigurationProvider: () -> YoutubeiNetworkConfiguration,
    ) : this(context, {}, networkConfigurationProvider)

    suspend fun preWarm() {
        // Nothing to warm: the QuickJS worker is not part of the desktop port.
    }

    suspend fun resolve(
        request: YoutubeiStreamRequest,
        priority: YoutubeiResolutionPriority,
        videoPoTokenProvider: suspend (String) -> String? = { null },
    ): YoutubeiResolvedStream =
        throw YoutubeiException(
            kind = YoutubeiFailureKind.INTERNAL,
            message = "stream resolution is not implemented in the desktop port",
        )

    suspend fun invalidateSessions() {}

    fun trimMemory(level: Int) {}
}
