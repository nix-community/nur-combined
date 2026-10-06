package androidx.media3.exoplayer.trackselection

/*
 * media3's ExoTrackSelection is an interface: SafeTrackSelector implements it by delegation
 * (`) : ExoTrackSelection by delegate {`), which only compiles for an interface.
 */
interface ExoTrackSelection {
    /* One entry in the definition array handed to Factory.createTrackSelections. */
    class Definition(
        val group: Any? = null,
        val tracks: Array<Int> = emptyArray(),
        val type: Int = 0,
    )

    fun isTrackExcluded(trackIndex: Int, nowMs: Long): Boolean = false

    fun length(): Int = 0

    fun excludeTrack(trackIndex: Int, exclusionDurationMs: Long): Boolean = false

    fun getSelectedIndex(): Int = 0

    fun getSelectionReason(): Int = 0

    fun getSelectionData(): Any? = null

    fun onPlaybackSpeed(speed: Float) {}

    fun updateSelectedTrack(
        playbackPositionUs: Long,
        bufferedDurationUs: Long,
        availableDurationUs: Long,
        pendingMediaPeriodIds: List<Any>,
    ) {}

    interface Factory {
        fun createTrackSelections(
            definitions: Array<out Definition?>,
            bandwidthMeter: androidx.media3.exoplayer.upstream.BandwidthMeter,
            mediaPeriodId: androidx.media3.exoplayer.source.MediaSource.MediaPeriodId,
            timeline: androidx.media3.common.Timeline,
        ): Array<ExoTrackSelection?> = emptyArray()
    }
}
