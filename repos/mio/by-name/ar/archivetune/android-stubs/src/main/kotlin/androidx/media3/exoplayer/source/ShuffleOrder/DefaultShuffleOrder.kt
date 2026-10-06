package androidx.media3.exoplayer.source.ShuffleOrder

/*
 * Upstream builds it as DefaultShuffleOrder(queueWindows, System.currentTimeMillis()); a vararg
 * constructor keeps every overload shape type-checking.
 */
open class DefaultShuffleOrder(
    vararg args: Any?,
) {
    companion object { }
}
