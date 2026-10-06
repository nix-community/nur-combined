package androidx.media3.exoplayer.trackselection

open class AdaptiveTrackSelection {
    class Factory(
        val bandwidthMeter: androidx.media3.exoplayer.upstream.BandwidthMeter? = null,
    ) : ExoTrackSelection.Factory {
        override fun createTrackSelections(
            definitions: Array<out ExoTrackSelection.Definition?>,
            bandwidthMeter: androidx.media3.exoplayer.upstream.BandwidthMeter,
            mediaPeriodId: androidx.media3.exoplayer.source.MediaSource.MediaPeriodId,
            timeline: androidx.media3.common.Timeline,
        ): Array<ExoTrackSelection?> = emptyArray()
    }

    companion object { }
}
