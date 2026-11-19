/*
 * Desktop stand-in for the Android-only USB bit-perfect output package.
 *
 * The real implementation drives AudioTrack and raw USB DAC endpoints, neither of
 * which exists on the JVM desktop. narrow.py drops that package; this file keeps
 * the small type surface the player and its settings screen reference.
 */
package moe.rukamori.archivetune.playback.bitperfect

import androidx.compose.runtime.Immutable

enum class BitPerfectFallback {
    NONE,
    UNAVAILABLE,
    NO_HARDWARE_VOLUME,
}

enum class BitPerfectEvent {
    OUTPUT_CHANGED,
    DAC_DETACHED,
}

@Immutable
data class BitPerfectStatus(
    val dacName: String? = null,
    val permissionRequired: Boolean = false,
    val active: Boolean = false,
    val exact: Boolean = false,
    val sampleRateHz: Int = 0,
    val outputBits: Int = 0,
    val fallback: BitPerfectFallback = BitPerfectFallback.UNAVAILABLE,
)

object BitPerfectOutput {
    val isMixerSupported: Boolean = false
}
