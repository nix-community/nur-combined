package moe.rukamori.archivetune.ui.screens.settings

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

/*
 * Upstream's Discord presence manager drives a local Discord RPC socket and OAuth
 * flow. The port has neither, so the discord package is dropped; this keeps the
 * small read-only surface the debug settings screen renders.
 */
object DiscordPresenceManager {
    val lastRpcStartTimeFlow: StateFlow<Long?> = MutableStateFlow(null)
    val lastRpcEndTimeFlow: StateFlow<Long?> = MutableStateFlow(null)

    fun isRunning(): Boolean = false
}
