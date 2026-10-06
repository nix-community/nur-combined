package androidx.media3.common

/*
 * Upstream configures the player with
 * `trackSelectionParameters = trackSelectionParameters.buildUpon().setTrackTypeDisabled(...).build()`.
 */
class TrackSelectionParameters {
    class Builder {
        fun setTrackTypeDisabled(trackType: Int, disabled: Boolean): Builder = this

        fun setTrackTypeDisabled(trackType: Int, disabled: Boolean, band: Any?): Builder = this

        fun setMaxVideoSize(maxVideoWidth: Int, maxVideoHeight: Int): Builder = this

        fun setMaxVideoBitrate(maxVideoBitrate: Int): Builder = this

        fun setMinVideoSize(minVideoWidth: Int, minVideoHeight: Int): Builder = this

        fun setPreferredAudioLanguage(language: String?): Builder = this

        fun setPreferredTextLanguage(language: String?): Builder = this

        fun build(): TrackSelectionParameters = TrackSelectionParameters()
    }

    val disabledTrackTypes: Set<Int> = emptySet()

    fun buildUpon(): Builder = Builder()

    companion object {
        val DEFAULT: TrackSelectionParameters = TrackSelectionParameters()
    }
}
