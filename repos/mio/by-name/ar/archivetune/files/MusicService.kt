package moe.rukamori.archivetune.playback

import android.content.ContentResolver
import android.content.Context
import android.net.ConnectivityManager
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.Commands
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.PlaybackParameters
import androidx.media3.common.Player
import androidx.media3.common.Timeline
import androidx.media3.common.Tracks
import androidx.media3.common.TrackSelectionParameters
import androidx.media3.common.VideoSize
import java.awt.EventQueue
import java.io.BufferedReader
import java.io.BufferedWriter
import java.io.File
import java.lang.reflect.Proxy
import java.net.UnixDomainSocketAddress
import java.nio.channels.Channels
import java.nio.channels.SocketChannel
import java.nio.charset.StandardCharsets
import java.util.concurrent.CopyOnWriteArrayList
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import androidx.datastore.preferences.DesktopPreferenceStore
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import moe.rukamori.archivetune.canvas.CanvasPlaybackUseCase
import moe.rukamori.archivetune.constants.AudioQuality
import moe.rukamori.archivetune.constants.HISTORY_DURATION_DEFAULT
import moe.rukamori.archivetune.constants.HISTORY_DURATION_MIN
import moe.rukamori.archivetune.constants.HISTORY_DURATION_MAX
import moe.rukamori.archivetune.constants.HistoryDuration
import moe.rukamori.archivetune.constants.PauseListenHistoryKey
import moe.rukamori.archivetune.db.entities.Event
import moe.rukamori.archivetune.db.MusicDatabase
import moe.rukamori.archivetune.extensions.metadata
import moe.rukamori.archivetune.extensions.toMediaItem
import moe.rukamori.archivetune.innertube.YouTube
import moe.rukamori.archivetune.models.ActiveOutputDevice
import moe.rukamori.archivetune.models.MediaMetadata
import moe.rukamori.archivetune.models.PlayerOutputDevice
import moe.rukamori.archivetune.playback.queues.Queue
import moe.rukamori.archivetune.together.TogetherSessionState
import moe.rukamori.archivetune.utils.YTPlayerUtils
import timber.log.Timber

/*
 * Upstream's MusicService is an Android MediaSessionService hosting playback, bound
 * by MediaLibrarySessionCallback and updated by MusicServiceWidgetUpdater.
 *
 * For Compose Multiplatform Desktop, DesktopPlayerImpl provides full reactive
 * playback state, playlist queueing, media item transition, and real audio decoding
 * and playback via an integrated mpv IPC player backend.
 */
class MusicService {
    class MusicBinder internal constructor(val service: MusicService)

    interface DesktopPlayer : Player {
        val currentMetadata: MediaMetadata?
    }

    class DesktopTimeline(val items: List<MediaItem>) : Timeline() {
        override val windowCount: Int get() = items.size
        override val periodCount: Int get() = items.size

        override fun getWindow(windowIndex: Int, window: Window): Window {
            if (windowIndex in items.indices) {
                val item = items[windowIndex]
                window.mediaItem = item
                window.firstPeriodIndex = windowIndex
                window.lastPeriodIndex = windowIndex
                val dur = (item.metadata?.duration?.toLong()?.times(1000L))
                    ?: (item.mediaMetadata.duration?.takeIf { it > 0 })
                    ?: 0L
                window.durationMs = if (dur > 0) dur else 180000L
            }
            return window
        }

        override fun getNextWindowIndex(
            windowIndex: Int,
            repeatMode: Int,
            shuffleModeEnabled: Boolean,
        ): Int {
            if (windowIndex + 1 < items.size) return windowIndex + 1
            if (repeatMode == Player.REPEAT_MODE_ALL && items.isNotEmpty()) return 0
            return -1
        }

        override fun getPreviousWindowIndex(
            windowIndex: Int,
            repeatMode: Int,
            shuffleModeEnabled: Boolean,
        ): Int {
            if (windowIndex - 1 >= 0) return windowIndex - 1
            if (repeatMode == Player.REPEAT_MODE_ALL && items.isNotEmpty()) return items.size - 1
            return -1
        }
    }

    class DesktopMpvPlayer(
        private val onPlaybackStateChanged: (isPlaying: Boolean) -> Unit,
        private val onPositionChanged: (posMs: Long) -> Unit,
        private val onDurationChanged: (durMs: Long) -> Unit,
        private val onTrackEnded: () -> Unit,
    ) {
        companion object {
            fun findMpvExecutable(): String? {
                val hardcoded = "@MPV_PATH@"
                if (hardcoded.isNotBlank() && !hardcoded.startsWith("@") && File(hardcoded).canExecute()) {
                    return hardcoded
                }
                val propPath = System.getProperty("archivetune.mpv.path") ?: System.getenv("ARCHIVETUNE_MPV_PATH")
                if (!propPath.isNullOrBlank() && File(propPath).canExecute()) {
                    return propPath
                }
                val pathEnv = System.getenv("PATH") ?: ""
                for (dir in pathEnv.split(File.pathSeparator)) {
                    val f = File(dir, "mpv")
                    if (f.canExecute()) return f.absolutePath
                }
                val fallbacks = listOf(
                    "/run/current-system/sw/bin/mpv",
                    "/nix/var/nix/profiles/default/bin/mpv",
                    "/opt/homebrew/bin/mpv",
                    "/usr/local/bin/mpv",
                    "/usr/bin/mpv"
                )
                for (p in fallbacks) {
                    val f = File(p)
                    if (f.canExecute()) return f.absolutePath
                }
                return null
            }
        }

        private var process: Process? = null
        private var socketChannel: SocketChannel? = null
        private var writer: BufferedWriter? = null
        private var readerThread: Thread? = null
        private var socketFile: File? = null

        @Volatile
        var currentPositionMs: Long = 0L
            private set

        @Volatile
        var durationMs: Long = 0L
            private set

        @Volatile
        var isPlaying: Boolean = false
            private set

        @Volatile
        var isConnected: Boolean = false
            private set

        private val lock = Any()

        private fun ensureStarted() {
            synchronized(lock) {
                if (process != null && process!!.isAlive && isConnected) return

                val mpv = findMpvExecutable()
                System.err.println("[ArchiveTune/Audio] Using mpv executable: $mpv")
                if (mpv == null) {
                    System.err.println("[ArchiveTune/Audio] ERROR: mpv executable not found on system")
                    return
                }

                try {
                    val sock = File(android.content.DesktopStoragePaths.runtimeDir, "archivetune-mpv-${ProcessHandle.current().pid()}.sock")
                    if (sock.exists()) sock.delete()
                    socketFile = sock

                    System.err.println("[ArchiveTune/Audio] Spawning mpv at $mpv with socket ${sock.absolutePath}")
                    val pb = ProcessBuilder(
                        mpv,
                        "--idle=yes",
                        "--no-video",
                        "--no-terminal",
                        "--input-ipc-server=${sock.absolutePath}"
                    )
                    pb.redirectErrorStream(true)
                    val proc = pb.start()
                    process = proc

                    Thread({
                        try {
                            proc.inputStream.bufferedReader().useLines { lines ->
                                lines.forEach { line ->
                                    System.err.println("[ArchiveTune/mpv] $line")
                                }
                            }
                        } catch (_: Throwable) {}
                    }, "mpv-logger").apply {
                        isDaemon = true
                        start()
                    }

                    var connected = false
                    val startConnect = System.currentTimeMillis()
                    val deadline = startConnect + 5000L
                    while (System.currentTimeMillis() < deadline) {
                        if (sock.exists()) {
                            try {
                                val channel = SocketChannel.open(UnixDomainSocketAddress.of(sock.toPath()))
                                socketChannel = channel
                                writer = BufferedWriter(Channels.newWriter(channel, StandardCharsets.UTF_8))
                                connected = true
                                break
                            } catch (_: Throwable) {
                                Thread.sleep(50)
                            }
                        } else {
                            Thread.sleep(50)
                        }
                    }

                    if (!connected) {
                        System.err.println("[ArchiveTune/Audio] ERROR: Timed out waiting for mpv IPC socket: ${sock.absolutePath}")
                        proc.destroy()
                        return
                    }

                    val elapsed = System.currentTimeMillis() - startConnect
                    System.err.println("[ArchiveTune/Audio] Connected to mpv IPC socket in ${elapsed}ms")
                    isConnected = true

                    val reader = BufferedReader(Channels.newReader(socketChannel!!, StandardCharsets.UTF_8))
                    readerThread = Thread({
                        try {
                            var line: String? = reader.readLine()
                            while (line != null) {
                                handleIpcMessage(line)
                                line = reader.readLine()
                            }
                        } catch (_: Throwable) {
                        } finally {
                            isConnected = false
                        }
                    }, "mpv-ipc-reader").apply {
                        isDaemon = true
                        start()
                    }

                    sendRaw("{\"command\": [\"observe_property\", 1, \"time-pos\"]}\n")
                    sendRaw("{\"command\": [\"observe_property\", 2, \"pause\"]}\n")
                    sendRaw("{\"command\": [\"observe_property\", 3, \"duration\"]}\n")
                    sendRaw("{\"command\": [\"observe_property\", 4, \"idle-active\"]}\n")

                    Runtime.getRuntime().addShutdownHook(Thread {
                        release()
                    })
                } catch (t: Throwable) {
                    System.err.println("[ArchiveTune/Audio] ERROR starting mpv: ${t.message}")
                    t.printStackTrace(System.err)
                }
            }
        }

        private fun sendRaw(msg: String) {
            synchronized(lock) {
                try {
                    writer?.write(msg)
                    writer?.flush()
                } catch (t: Throwable) {
                    System.err.println("[ArchiveTune/Audio] ERROR sending raw command to mpv: ${t.message}")
                }
            }
        }

        fun load(url: String, startPosMs: Long, playWhenReady: Boolean) {
            ensureStarted()
            System.err.println("[ArchiveTune/Audio] mpv.load: url=$url, startPosMs=$startPosMs, playWhenReady=$playWhenReady, isConnected=$isConnected")
            val escaped = url.replace("\\", "\\\\").replace("\"", "\\\"")
            sendRaw("{\"command\": [\"loadfile\", \"$escaped\", \"replace\"]}\n")
            if (startPosMs > 0) {
                val secs = startPosMs / 1000.0
                sendRaw("{\"command\": [\"seek\", $secs, \"absolute\"]}\n")
            }
            sendRaw("{\"command\": [\"set_property\", \"pause\", ${!playWhenReady}]}\n")
            if (playWhenReady) {
                isPlaying = true
                onPlaybackStateChanged(true)
            }
        }

        fun play() {
            ensureStarted()
            sendRaw("{\"command\": [\"set_property\", \"pause\", false]}\n")
            isPlaying = true
            onPlaybackStateChanged(true)
        }

        fun pause() {
            sendRaw("{\"command\": [\"set_property\", \"pause\", true]}\n")
            isPlaying = false
            onPlaybackStateChanged(false)
        }

        fun seekTo(posMs: Long) {
            ensureStarted()
            val secs = posMs / 1000.0
            sendRaw("{\"command\": [\"seek\", $secs, \"absolute\"]}\n")
            currentPositionMs = posMs
            onPositionChanged(posMs)
        }

        fun setVolume(vol: Float) {
            val pct = (vol.coerceIn(0f, 1f) * 100).toInt()
            sendRaw("{\"command\": [\"set_property\", \"volume\", $pct]}\n")
        }

        fun stop() {
            sendRaw("{\"command\": [\"stop\"]}\n")
            isPlaying = false
            currentPositionMs = 0L
            onPlaybackStateChanged(false)
        }

        fun release() {
            synchronized(lock) {
                try {
                    sendRaw("{\"command\": [\"quit\"]}\n")
                    socketChannel?.close()
                    process?.destroy()
                    socketFile?.delete()
                } catch (_: Throwable) {
                }
            }
        }

        private fun handleIpcMessage(json: String) {
            if (!json.contains("time-pos")) {
                System.err.println("[ArchiveTune/IPC] $json")
            }
            if (json.contains("\"event\":\"property-change\"")) {
                if (json.contains("\"name\":\"time-pos\"")) {
                    val data = extractDouble(json, "data")
                    if (data != null && data >= 0) {
                        val posMs = (data * 1000).toLong()
                        currentPositionMs = posMs
                        onPositionChanged(posMs)
                    }
                } else if (json.contains("\"name\":\"pause\"")) {
                    val paused = extractBoolean(json, "data")
                    if (paused != null) {
                        val playing = !paused
                        if (isPlaying != playing) {
                            isPlaying = playing
                            onPlaybackStateChanged(playing)
                        }
                    }
                } else if (json.contains("\"name\":\"duration\"")) {
                    val data = extractDouble(json, "data")
                    if (data != null && data > 0) {
                        val durMs = (data * 1000).toLong()
                        durationMs = durMs
                        onDurationChanged(durMs)
                    }
                }
            } else if (json.contains("\"event\":\"end-file\"")) {
                if (json.contains("\"reason\":\"eof\"")) {
                    onTrackEnded()
                }
            } else if (json.contains("\"event\":\"playback-restart\"")) {
                isPlaying = true
                onPlaybackStateChanged(true)
            }
        }

        private fun extractDouble(json: String, key: String): Double? {
            val match = Regex("\"$key\"\\s*:\\s*([0-9.]+)").find(json)
            return match?.groupValues?.get(1)?.toDoubleOrNull()
        }

        private fun extractBoolean(json: String, key: String): Boolean? {
            val match = Regex("\"$key\"\\s*:\\s*(true|false)").find(json)
            return match?.groupValues?.get(1)?.toBooleanStrictOrNull()
        }
    }

    class DesktopPlayerImpl(private val service: MusicService) : DesktopPlayer {
        val listeners = CopyOnWriteArrayList<Player.Listener>()
        val mediaItems = mutableListOf<MediaItem>()

        override var currentMediaItemIndex: Int = -1
            private set

        private var _timeline: Timeline = Timeline.EMPTY
        override val currentTimeline: Timeline get() = _timeline

        override val mediaItemCount: Int get() = mediaItems.size
        override val currentMediaItem: MediaItem? get() = mediaItems.getOrNull(currentMediaItemIndex)
        override val currentMetadata: MediaMetadata?
            get() = currentMediaItem?.metadata ?: service.currentMediaMetadata.value

        private fun runOnMain(block: () -> Unit) {
            if (EventQueue.isDispatchThread()) {
                block()
            } else {
                EventQueue.invokeLater(block)
            }
        }

        private val mpvPlayer = DesktopMpvPlayer(
            onPlaybackStateChanged = { playing ->
                runOnMain {
                    if (_isPlaying != playing) {
                        _isPlaying = playing
                        if (playing) {
                            playbackState = Player.STATE_READY
                            playStartTime = System.currentTimeMillis() - pausedPosition
                        }
                        service.historyTracker.onPlaybackStateChanged(playing)
                        listeners.forEach {
                            it.onPlaybackStateChanged(playbackState)
                            it.onIsPlayingChanged(playing)
                        }
                    }
                }
            },
            onPositionChanged = { posMs ->
                pausedPosition = posMs
                playStartTime = System.currentTimeMillis()
            },
            onDurationChanged = { _ ->
            },
            onTrackEnded = {
                runOnMain {
                    service.historyTracker.finalizeCurrentSession()
                    if (repeatMode == Player.REPEAT_MODE_ONE) {
                        seekTo(currentMediaItemIndex, 0L)
                    } else if (hasNextMediaItem()) {
                        seekToNext()
                    } else if (repeatMode == Player.REPEAT_MODE_ALL && mediaItems.isNotEmpty()) {
                        seekTo(0, 0L)
                    } else {
                        stop()
                    }
                }
            }
        )

        private fun checkQueueContinuation() {
            if (mediaItems.isNotEmpty() && currentMediaItemIndex >= mediaItems.size - 3) {
                service.loadMoreQueueItems()
            }
        }

        private var currentPlayingId: String? = null

        private fun loadTrack(mediaId: String, startPositionMs: Long, playWhenReady: Boolean) {
            checkQueueContinuation()
            val cleanId = mediaId.trim().removePrefix("song/")
            if (cleanId.isBlank()) {
                System.err.println("[ArchiveTune/Audio] loadTrack called with blank mediaId, ignoring")
                return
            }
            currentPlayingId = cleanId
            System.err.println("[ArchiveTune/Audio] loadTrack: mediaId=$cleanId, startPositionMs=$startPositionMs, playWhenReady=$playWhenReady")

            CoroutineScope(Dispatchers.IO).launch {
                var finalUrl = if (cleanId.startsWith("http://") || cleanId.startsWith("https://") || cleanId.startsWith("file://") || cleanId.startsWith("/")) {
                    cleanId
                } else {
                    "https://www.youtube.com/watch?v=$cleanId"
                }

                if (finalUrl.startsWith("https://www.youtube.com/watch?v=")) {
                    try {
                        withTimeoutOrNull(8000L) {
                            val resp = YTPlayerUtils.playerResponseForPlayback(
                                videoId = cleanId,
                                audioQuality = AudioQuality.AUTO,
                                connectivityManager = ConnectivityManager()
                            )
                            val streamUrl = resp.getOrNull()?.streamUrl
                            if (!streamUrl.isNullOrBlank()) {
                                System.err.println("[ArchiveTune/Audio] Resolved direct stream URL from Innertube: $streamUrl")
                                finalUrl = streamUrl
                            } else {
                                val err = resp.exceptionOrNull()
                                System.err.println("[ArchiveTune/Audio] Innertube streamUrl was null/blank (err=$err), falling back to $finalUrl")
                            }
                        }
                    } catch (t: Throwable) {
                        System.err.println("[ArchiveTune/Audio] Stream resolution warning: ${t.message}")
                    }
                }

                System.err.println("[ArchiveTune/Audio] Passing URL to mpv: $finalUrl")
                mpvPlayer.load(finalUrl, startPositionMs, playWhenReady)
            }
        }

        override var playWhenReady: Boolean = false
            set(value) {
                field = value
                if (value && playbackState == Player.STATE_READY) {
                    if (!_isPlaying) {
                        _isPlaying = true
                        playStartTime = System.currentTimeMillis() - pausedPosition
                        service.historyTracker.onPlaybackStateChanged(true)
                        mpvPlayer.play()
                        listeners.forEach {
                            it.onIsPlayingChanged(true)
                            it.onPlayWhenReadyChanged(true, Player.PLAY_WHEN_READY_CHANGE_REASON_USER_REQUEST)
                        }
                    }
                } else if (!value && _isPlaying) {
                    pausedPosition = currentPosition
                    _isPlaying = false
                    service.historyTracker.onPlaybackStateChanged(false)
                    mpvPlayer.pause()
                    listeners.forEach {
                        it.onIsPlayingChanged(false)
                        it.onPlayWhenReadyChanged(false, Player.PLAY_WHEN_READY_CHANGE_REASON_USER_REQUEST)
                    }
                }
            }

        override var playbackState: Int = Player.STATE_IDLE
            private set

        private var _isPlaying: Boolean = false
        override val isPlaying: Boolean get() = _isPlaying

        override val isLoading: Boolean get() = playbackState == Player.STATE_BUFFERING

        private var playStartTime: Long = 0L
        private var pausedPosition: Long = 0L

        override val currentPosition: Long
            get() {
                val mpvPos = mpvPlayer.currentPositionMs
                if (mpvPos > 0) return mpvPos
                if (!_isPlaying) return pausedPosition
                val elapsed = System.currentTimeMillis() - playStartTime
                val pos = pausedPosition + elapsed
                val dur = duration
                if (dur > 0 && pos >= dur) {
                    return dur
                }
                return pos
            }

        override val duration: Long
            get() {
                val mpvDur = mpvPlayer.durationMs
                if (mpvDur > 0) return mpvDur
                val dur = currentMetadata?.duration
                if (dur != null && dur > 0) return dur.toLong() * 1000L
                return 180000L
            }

        override val bufferedPosition: Long get() = duration
        override val totalBufferedDuration: Long get() = duration
        override val bufferedPercentage: Int get() = 100

        override var repeatMode: Int = Player.REPEAT_MODE_OFF
            set(value) {
                field = value
                listeners.forEach { it.onRepeatModeChanged(value) }
            }

        override var shuffleModeEnabled: Boolean = false
            set(value) {
                field = value
                listeners.forEach { it.onShuffleModeEnabledChanged(value) }
            }

        override var playbackParameters: PlaybackParameters = PlaybackParameters.DEFAULT
            set(value) {
                field = value
                listeners.forEach { it.onPlaybackParametersChanged(value) }
            }

        override var trackSelectionParameters: TrackSelectionParameters = TrackSelectionParameters()
        override var volume: Float = 1.0f
            set(value) {
                field = value
                mpvPlayer.setVolume(value)
                listeners.forEach { it.onVolumeChanged(value) }
            }

        override val audioSessionId: Int get() = 0
        override val availableCommands: Commands = Commands()
        override val videoSize: VideoSize? get() = null
        override val playerError: PlaybackException? get() = null
        override val isInitialized: Boolean get() = true
        override val pauseAtEndOfMediaItems: Boolean get() = false
        override val maxSeekToPreviousPosition: Long get() = 3000L
        override val isCurrentMediaItemLive: Boolean get() = false
        override val isCurrentMediaItemSeekable: Boolean get() = true
        override val isCurrentMediaItemDynamic: Boolean get() = false

        override val nextMediaItemIndex: Int
            get() = if (currentMediaItemIndex + 1 < mediaItems.size) currentMediaItemIndex + 1 else -1

        override val previousMediaItemIndex: Int
            get() = if (currentMediaItemIndex > 0) currentMediaItemIndex - 1 else -1

        override fun hasNextMediaItem(): Boolean = nextMediaItemIndex != -1
        override fun hasPreviousMediaItem(): Boolean = previousMediaItemIndex != -1
        override fun hasNext(): Boolean = hasNextMediaItem()
        override fun hasPrevious(): Boolean = hasPreviousMediaItem()

        override fun isCommandAvailable(command: Int): Boolean {
            return when (command) {
                Player.COMMAND_SEEK_TO_NEXT_MEDIA_ITEM, Player.COMMAND_SEEK_TO_NEXT -> hasNextMediaItem()
                Player.COMMAND_SEEK_TO_PREVIOUS_MEDIA_ITEM, Player.COMMAND_SEEK_TO_PREVIOUS -> hasPreviousMediaItem()
                else -> true
            }
        }

        override fun prepare() {
            if (playbackState == Player.STATE_IDLE && mediaItems.isNotEmpty()) {
                playbackState = Player.STATE_READY
                listeners.forEach { it.onPlaybackStateChanged(playbackState) }
            }
        }

        override fun play() {
            prepare()
            playWhenReady = true
            if (!_isPlaying) {
                _isPlaying = true
                playStartTime = System.currentTimeMillis() - pausedPosition
                service.historyTracker.onPlaybackStateChanged(true)
                mpvPlayer.play()
                listeners.forEach {
                    it.onPlaybackStateChanged(playbackState)
                    it.onIsPlayingChanged(true)
                }
            }
        }

        override fun pause() {
            if (_isPlaying) {
                pausedPosition = currentPosition
                _isPlaying = false
                playWhenReady = false
                service.historyTracker.onPlaybackStateChanged(false)
                mpvPlayer.pause()
                listeners.forEach { it.onIsPlayingChanged(false) }
            }
        }

        override fun togglePlayPause() {
            if (_isPlaying) pause() else play()
        }

        override fun toggleRepeatMode() {
            repeatMode = when (repeatMode) {
                Player.REPEAT_MODE_OFF -> Player.REPEAT_MODE_ALL
                Player.REPEAT_MODE_ALL -> Player.REPEAT_MODE_ONE
                else -> Player.REPEAT_MODE_OFF
            }
        }

        override fun stop() {
            service.historyTracker.finalizeCurrentSession()
            pause()
            playbackState = Player.STATE_IDLE
            currentPlayingId = null
            mpvPlayer.stop()
            listeners.forEach { it.onPlaybackStateChanged(playbackState) }
        }

        override fun release() {
            service.historyTracker.finalizeCurrentSession()
            stop()
            mpvPlayer.release()
            listeners.clear()
        }

        override fun seekToDefaultPosition() {
            seekTo(0L)
        }

        override fun seekToDefaultPosition(mediaItemIndex: Int) {
            seekTo(mediaItemIndex, 0L)
        }

        override fun seekTo(positionMs: Long) {
            seekTo(currentMediaItemIndex, positionMs)
        }

        override fun seekTo(mediaItemIndex: Int, positionMs: Long) {
            if (mediaItemIndex in mediaItems.indices) {
                val itemChanged = currentMediaItemIndex != mediaItemIndex
                currentMediaItemIndex = mediaItemIndex
                pausedPosition = positionMs
                playStartTime = System.currentTimeMillis()
                val item = currentMediaItem
                val meta = item?.metadata
                if (meta != null) {
                    service.currentMediaMetadata.value = meta
                }
                if (itemChanged) {
                    val targetId = meta?.id ?: item?.mediaId ?: ""
                    service.historyTracker.onMediaItemTransition(targetId)
                    loadTrack(targetId, positionMs, playWhenReady)
                    listeners.forEach {
                        it.onMediaItemTransition(item, Player.MEDIA_ITEM_TRANSITION_REASON_SEEK)
                    }
                } else {
                    mpvPlayer.seekTo(positionMs)
                }
                listeners.forEach {
                    it.onPositionDiscontinuity(
                        Player.PositionInfo(mediaItemIndex, positionMs, item),
                        Player.PositionInfo(mediaItemIndex, positionMs, item),
                        Player.DISCONTINUITY_REASON_SEEK
                    )
                }
            }
        }

        override fun seekToPrevious() {
            if (currentPosition > 3000L || previousMediaItemIndex == -1) {
                seekTo(0L)
            } else {
                seekTo(previousMediaItemIndex, 0L)
            }
        }

        override fun seekToNext() {
            if (nextMediaItemIndex != -1) {
                seekTo(nextMediaItemIndex, 0L)
            }
        }

        override fun seekToPreviousMediaItem() = seekToPrevious()
        override fun seekToNextMediaItem() = seekToNext()

        override fun setMediaItem(mediaItem: MediaItem) {
            setMediaItems(listOf(mediaItem))
        }

        override fun setMediaItem(mediaItem: MediaItem, resetPosition: Boolean) {
            setMediaItems(listOf(mediaItem), resetPosition)
        }

        override fun setMediaItems(mediaItems: List<MediaItem>) {
            setMediaItems(mediaItems, 0, 0L)
        }

        override fun setMediaItems(mediaItems: List<MediaItem>, resetPosition: Boolean) {
            val startPos = if (resetPosition) 0L else currentPosition
            setMediaItems(mediaItems, 0, startPos)
        }

        override fun setMediaItems(mediaItems: List<MediaItem>, startIndex: Int, startPositionMs: Long) {
            val previousId = currentMediaItem?.metadata?.id?.takeIf { it.isNotBlank() } ?: currentMediaItem?.mediaId?.takeIf { it.isNotBlank() }
            this.mediaItems.clear()
            this.mediaItems.addAll(mediaItems)
            _timeline = DesktopTimeline(this.mediaItems)
            currentMediaItemIndex = if (this.mediaItems.isNotEmpty()) startIndex.coerceIn(this.mediaItems.indices) else -1
            pausedPosition = startPositionMs
            playStartTime = System.currentTimeMillis()
            playbackState = if (this.mediaItems.isNotEmpty()) Player.STATE_READY else Player.STATE_IDLE
            val item = currentMediaItem
            val meta = item?.metadata
            if (meta != null) {
                service.currentMediaMetadata.value = meta
            } else if (item != null && item.mediaId.isNotBlank()) {
                val fallbackMeta = MediaMetadata(
                    id = item.mediaId,
                    title = item.mediaMetadata.title?.toString() ?: "Unknown",
                    artists = listOfNotNull(item.mediaMetadata.artist?.toString()?.let { moe.rukamori.archivetune.models.MediaMetadata.Artist(id = null, name = it) }),
                    duration = (item.mediaMetadata.duration ?: 0L).toInt() / 1000,
                    thumbnailUrl = item.mediaMetadata.artworkUri?.toString() ?: "https://i.ytimg.com/vi/${item.mediaId}/hqdefault.jpg"
                )
                service.currentMediaMetadata.value = fallbackMeta
            }
            listeners.forEach {
                it.onTimelineChanged(_timeline, Player.TIMELINE_CHANGE_REASON_PLAYLIST_CHANGED)
                it.onMediaItemTransition(item, Player.MEDIA_ITEM_TRANSITION_REASON_PLAYLIST_CHANGED)
                it.onPlaybackStateChanged(playbackState)
            }

            val newId = meta?.id?.takeIf { it.isNotBlank() }
                ?: item?.mediaId?.takeIf { it.isNotBlank() }
                ?: service.currentMediaMetadata.value?.id?.takeIf { it.isNotBlank() }

            service.historyTracker.onMediaItemTransition(newId)

            System.err.println("[ArchiveTune/Audio] setMediaItems: count=${mediaItems.size}, startIndex=$startIndex, currentMediaItemIndex=$currentMediaItemIndex, newId=$newId, previousId=$previousId, currentPlayingId=$currentPlayingId")

            if (newId != null && (newId != previousId || newId != currentPlayingId)) {
                loadTrack(newId, startPositionMs, playWhenReady)
            }
        }

        override fun addMediaItem(mediaItem: MediaItem) {
            addMediaItems(listOf(mediaItem))
        }

        override fun addMediaItem(index: Int, mediaItem: MediaItem) {
            addMediaItems(index, listOf(mediaItem))
        }

        override fun addMediaItems(mediaItems: List<MediaItem>) {
            addMediaItems(this.mediaItems.size, mediaItems)
        }

        override fun addMediaItems(index: Int, mediaItems: List<MediaItem>) {
            val insertAt = index.coerceIn(0, this.mediaItems.size)
            this.mediaItems.addAll(insertAt, mediaItems)
            _timeline = DesktopTimeline(this.mediaItems)
            if (currentMediaItemIndex == -1 && this.mediaItems.isNotEmpty()) {
                currentMediaItemIndex = 0
                val item = currentMediaItem
                val meta = item?.metadata
                if (meta != null) {
                    service.currentMediaMetadata.value = meta
                }
                val newId = meta?.id ?: item?.mediaId
                service.historyTracker.onMediaItemTransition(newId)
                listeners.forEach {
                    it.onMediaItemTransition(item, Player.MEDIA_ITEM_TRANSITION_REASON_PLAYLIST_CHANGED)
                }
                val trackId = newId
                if (trackId != null && trackId != currentPlayingId) {
                    loadTrack(trackId, 0L, playWhenReady)
                }
            }
            listeners.forEach {
                it.onTimelineChanged(_timeline, Player.TIMELINE_CHANGE_REASON_PLAYLIST_CHANGED)
            }
        }

        override fun removeMediaItem(index: Int) {
            removeMediaItems(index, index + 1)
        }

        override fun removeMediaItems(fromIndex: Int, toIndex: Int) {
            if (fromIndex in 0 until toIndex && toIndex <= mediaItems.size) {
                mediaItems.subList(fromIndex, toIndex).clear()
                _timeline = DesktopTimeline(mediaItems)
                if (currentMediaItemIndex in fromIndex until toIndex) {
                    currentMediaItemIndex = currentMediaItemIndex.coerceIn(0, maxOf(0, mediaItems.size - 1))
                } else if (currentMediaItemIndex >= toIndex) {
                    currentMediaItemIndex -= (toIndex - fromIndex)
                }
                listeners.forEach {
                    it.onTimelineChanged(_timeline, Player.TIMELINE_CHANGE_REASON_PLAYLIST_CHANGED)
                }
            }
        }

        override fun clearMediaItems() {
            service.historyTracker.finalizeCurrentSession()
            service.historyTracker.onMediaItemTransition(null)
            mediaItems.clear()
            _timeline = Timeline.EMPTY
            currentMediaItemIndex = -1
            pausedPosition = 0L
            currentPlayingId = null
            mpvPlayer.stop()
            listeners.forEach {
                it.onTimelineChanged(_timeline, Player.TIMELINE_CHANGE_REASON_PLAYLIST_CHANGED)
                it.onMediaItemTransition(null, Player.MEDIA_ITEM_TRANSITION_REASON_PLAYLIST_CHANGED)
            }
        }

        override fun moveMediaItem(currentIndex: Int, newIndex: Int) {
            if (currentIndex in mediaItems.indices && newIndex in mediaItems.indices && currentIndex != newIndex) {
                val item = mediaItems.removeAt(currentIndex)
                mediaItems.add(newIndex, item)
                _timeline = DesktopTimeline(mediaItems)
                if (currentMediaItemIndex == currentIndex) {
                    currentMediaItemIndex = newIndex
                } else if (currentMediaItemIndex in minOf(currentIndex, newIndex)..maxOf(currentIndex, newIndex)) {
                    if (currentIndex < newIndex) currentMediaItemIndex-- else currentMediaItemIndex++
                }
                listeners.forEach {
                    it.onTimelineChanged(_timeline, Player.TIMELINE_CHANGE_REASON_PLAYLIST_CHANGED)
                }
            }
        }

        override fun moveMediaItems(fromIndex: Int, toIndex: Int, newIndex: Int) {}

        override fun replaceMediaItem(index: Int, mediaItem: MediaItem) {
            if (index in mediaItems.indices) {
                mediaItems[index] = mediaItem
                _timeline = DesktopTimeline(mediaItems)
                if (index == currentMediaItemIndex) {
                    val meta = mediaItem.metadata
                    if (meta != null) service.currentMediaMetadata.value = meta
                }
                listeners.forEach {
                    it.onTimelineChanged(_timeline, Player.TIMELINE_CHANGE_REASON_PLAYLIST_CHANGED)
                }
            }
        }

        override fun replaceMediaItems(fromIndex: Int, toIndex: Int, mediaItems: List<MediaItem>) {
            removeMediaItems(fromIndex, toIndex)
            addMediaItems(fromIndex, mediaItems)
        }

        override fun getMediaItemAt(index: Int): MediaItem = mediaItems[index]

        override fun setPlaybackSpeed(speed: Float) {
            playbackParameters = PlaybackParameters(speed)
        }

        override fun setShuffleOrder(shuffleOrder: Any) {}
        override fun setVideoSurface(surface: Any?) {}
        override fun clearVideoSurface(surface: Any?) {}
        override fun clearVideoSurface() {}
        override fun setVideoSurfaceTexture(surfaceTexture: Any?) {}
        override fun clearVideoSurfaceTexture() {}
        override fun setPauseAtEndOfMediaItems(pauseAtEndOfMediaItems: Boolean) {}

        override fun addListener(listener: Player.Listener) {
            listeners.addIfAbsent(listener)
        }

        override fun removeListener(listener: Player.Listener) {
            listeners.remove(listener)
        }
    }

    class DesktopHistoryTracker(
        private val scope: CoroutineScope,
        private val getPlayer: () -> DesktopPlayer,
        private val getCurrentMetadata: () -> MediaMetadata?,
    ) {
        private var currentMediaId: String? = null
        private var sessionToken: Long = 0L
        private var accumulatedPlayMs: Long = 0L
        private var startedAtElapsedMs: Long? = null
        private var eventId: Long? = null
        private var immediateRecorded: Boolean = false
        private var finalized: Boolean = false
        private var insertResult: CompletableDeferred<Long?>? = null

        private fun historyThresholdMs(): Long {
            val duration = runCatching {
                DesktopPreferenceStore.currentPreferences[HistoryDuration]
            }.getOrNull() ?: HISTORY_DURATION_DEFAULT
            return duration.coerceIn(HISTORY_DURATION_MIN, HISTORY_DURATION_MAX).toLong() * 1000L
        }

        private fun isHistoryPaused(): Boolean {
            return runCatching {
                DesktopPreferenceStore.currentPreferences[PauseListenHistoryKey]
            }.getOrNull() ?: false
        }

        private fun currentPlayedMs(): Long {
            val running = startedAtElapsedMs?.let {
                (System.currentTimeMillis() - it).coerceAtLeast(0L)
            } ?: 0L
            return accumulatedPlayMs + running
        }

        @Synchronized
        fun onMediaItemTransition(newMediaId: String?) {
            val normalized = newMediaId?.trim()?.removePrefix("song/")?.takeIf { it.isNotEmpty() }
            if (normalized == currentMediaId && sessionToken != 0L && !finalized) {
                refreshSongMetadata()
                return
            }
            finalizeCurrentSession()

            currentMediaId = normalized
            sessionToken++
            accumulatedPlayMs = 0L
            startedAtElapsedMs = null
            eventId = null
            immediateRecorded = false
            finalized = false
            insertResult = null

            updatePlaybackState(getPlayer().isPlaying)
        }

        @Synchronized
        fun onPlaybackStateChanged(isPlaying: Boolean) {
            updatePlaybackState(isPlaying)
        }

        private fun updatePlaybackState(isPlaying: Boolean) {
            val mediaId = currentMediaId ?: return
            if (isHistoryPaused()) {
                startedAtElapsedMs = null
                return
            }

            if (finalized) {
                if (!isPlaying) return
                // Replaying/resuming the same item after a finalized session starts a new one.
                sessionToken++
                accumulatedPlayMs = 0L
                startedAtElapsedMs = null
                eventId = null
                immediateRecorded = false
                finalized = false
                insertResult = null
            }

            if (isPlaying) {
                if (startedAtElapsedMs == null) {
                    startedAtElapsedMs = System.currentTimeMillis()
                }
            } else {
                startedAtElapsedMs?.let {
                    accumulatedPlayMs += (System.currentTimeMillis() - it).coerceAtLeast(0L)
                }
                startedAtElapsedMs = null
            }

            syncThresholdJob()
        }

        private fun syncThresholdJob() {
            val mediaId = currentMediaId ?: return
            if (finalized) return
            if (isHistoryPaused()) return
            if (immediateRecorded) return
            // The history list shows the song as soon as playback starts. The duration
            // preference still decides when the session counts as a listen.
            if (!getPlayer().isPlaying && currentPlayedMs() <= 0L) return
            recordHistoryEvent(mediaId, currentPlayedMs())
        }

        private fun recordHistoryEvent(mediaId: String, playedMs: Long) {
            if (isHistoryPaused() || immediateRecorded) return
            immediateRecorded = true
            val meta = getCurrentMetadata()?.takeIf { it.id == mediaId }
            val currentToken = sessionToken
            val deferred = CompletableDeferred<Long?>()
            insertResult = deferred

            scope.launch(Dispatchers.IO) {
                var newEventId: Long? = null
                try {
                    val db = androidx.hilt.navigation.compose.getGlobalMusicDatabase() as? MusicDatabase
                    if (db == null) {
                        System.err.println("[ArchiveTune/History] Music database unavailable; not recording $mediaId")
                    } else {
                        ensureSongInDatabase(db, mediaId, meta)
                        val inserted = db.insert(
                            Event(
                                songId = mediaId,
                                timestamp = java.time.LocalDateTime.now(),
                                playTime = playedMs,
                            )
                        )
                        if (inserted > 0L) {
                            newEventId = inserted
                            System.err.println("[ArchiveTune/History] Recorded playback history for $mediaId (eventId=$inserted, playedMs=$playedMs)")
                            YouTube.notifyHistorySynced()
                        } else {
                            System.err.println("[ArchiveTune/History] Event insert ignored for $mediaId (rowId=$inserted)")
                        }
                    }
                } catch (t: Throwable) {
                    System.err.println("[ArchiveTune/History] Failed to record playback history for $mediaId: ${t.message}")
                    t.printStackTrace()
                } finally {
                    deferred.complete(newEventId)
                    synchronized(this@DesktopHistoryTracker) {
                        if (sessionToken == currentToken) {
                            if (newEventId != null) {
                                eventId = newEventId
                            } else {
                                immediateRecorded = false
                            }
                        }
                    }
                }
                if (newEventId != null) {
                    try {
                        registerRemotePlayback(mediaId)
                    } catch (t: Throwable) {
                        System.err.println("[ArchiveTune/History] Remote history sync failed for $mediaId: ${t.message}")
                    }
                }
            }
        }

        private fun refreshSongMetadata() {
            val mediaId = currentMediaId ?: return
            val meta = getCurrentMetadata()?.takeIf {
                it.id == mediaId && it.title.isNotBlank() && it.title != "Playing..."
            } ?: return
            scope.launch(Dispatchers.IO) {
                val db = androidx.hilt.navigation.compose.getGlobalMusicDatabase() as? MusicDatabase ?: return@launch
                if (ensureSongInDatabase(db, mediaId, meta)) {
                    YouTube.notifyHistorySynced()
                }
            }
        }

        private suspend fun ensureSongInDatabase(db: MusicDatabase, mediaId: String, meta: MediaMetadata?): Boolean {
            val existing = db.getSongById(mediaId)
            val realMeta = meta?.takeIf { it.title.isNotBlank() && it.title != "Playing..." }
            if (realMeta != null && existing != null &&
                (existing.song.title == "Unknown Title" || existing.song.title == "Playing...")
            ) {
                db.update(existing, realMeta)
                return true
            }
            val songToInsert = if (realMeta != null && existing == null) {
                realMeta
            } else if (existing == null) {
                MediaMetadata(
                    id = mediaId,
                    title = "Unknown Title",
                    artists = meta?.artists?.takeIf { it.isNotEmpty() } ?: listOf(MediaMetadata.Artist(id = null, name = "Unknown Artist")),
                    duration = meta?.duration ?: 0,
                    thumbnailUrl = meta?.thumbnailUrl ?: "https://i.ytimg.com/vi/$mediaId/hqdefault.jpg"
                )
            } else {
                null
            }
            if (songToInsert == null) return false
            try {
                db.insert(songToInsert)
            } catch (t: Throwable) {
                System.err.println("[ArchiveTune/History] Song metadata insert failed for $mediaId: ${t.message}")
                if (db.getSongById(mediaId) == null) {
                    db.insert(songToInsert.toSongEntity())
                }
            }
            return true
        }

        @Synchronized
        fun finalizeCurrentSession() {
            val mediaId = currentMediaId ?: return
            if (finalized) return
            finalized = true
            val started = startedAtElapsedMs
            if (started != null) {
                accumulatedPlayMs += (System.currentTimeMillis() - started).coerceAtLeast(0L)
                startedAtElapsedMs = null
            }

            val totalPlayed = accumulatedPlayMs
            val existingEventId = eventId
            val pendingInsert = insertResult
            val meta = getCurrentMetadata()?.takeIf { it.id == mediaId }
            val thresholdMs = historyThresholdMs()
            val paused = isHistoryPaused()
            if (paused) return
            if (totalPlayed <= 0L && pendingInsert == null && existingEventId == null) return

            scope.launch(Dispatchers.IO) {
                val insertedId = try {
                    pendingInsert?.await()
                } catch (t: Throwable) {
                    System.err.println("[ArchiveTune/History] History insert did not finish for $mediaId: ${t.message}")
                    null
                }
                try {
                    val db = androidx.hilt.navigation.compose.getGlobalMusicDatabase() as? MusicDatabase ?: return@launch
                    ensureSongInDatabase(db, mediaId, meta)
                    val targetEventId = existingEventId ?: insertedId?.takeIf { it > 0L }
                        ?: if (totalPlayed > 0L || pendingInsert != null) {
                            db.insert(
                                Event(
                                    songId = mediaId,
                                    timestamp = java.time.LocalDateTime.now(),
                                    playTime = totalPlayed,
                                )
                            ).takeIf { it > 0L }
                        } else {
                            null
                        }

                    if (targetEventId != null) {
                        db.updateEventPlayTime(targetEventId, totalPlayed)
                        YouTube.notifyHistorySynced()
                    }
                    if (totalPlayed >= thresholdMs) {
                        db.incrementTotalPlayTime(mediaId, totalPlayed)
                        db.incrementPlayCount(mediaId)
                    }
                    if (targetEventId != null) {
                        System.err.println("[ArchiveTune/History] Finalized history session for $mediaId (totalPlayedMs=$totalPlayed, eventId=$targetEventId)")
                    }
                } catch (t: Throwable) {
                    System.err.println("[ArchiveTune/History] Failed to finalize history session for $mediaId: ${t.message}")
                    t.printStackTrace()
                }
            }
        }

        private suspend fun registerRemotePlayback(mediaId: String) {
            try {
                val response = YTPlayerUtils.playerResponseForMetadata(mediaId)
                val trackingUrl = response.getOrNull()?.playbackTracking?.videostatsPlaybackUrl?.baseUrl
                if (!trackingUrl.isNullOrBlank()) {
                    YouTube.registerPlayback(playlistId = null, playbackTracking = trackingUrl)
                        .onSuccess { YouTube.notifyHistorySynced() }
                }
            } catch (_: Throwable) {}
        }
    }

    val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    val historyTracker = DesktopHistoryTracker(
        scope = serviceScope,
        getPlayer = { desktopPlayerImpl },
        getCurrentMetadata = { currentMediaMetadata.value }
    )

    private val desktopPlayerImpl = DesktopPlayerImpl(this)
    val player: DesktopPlayer get() = desktopPlayerImpl
    val localPlayer: DesktopPlayer get() = desktopPlayerImpl

    val currentMediaMetadata = MutableStateFlow<MediaMetadata?>(null)
    val sleepTimer by lazy { SleepTimer(CoroutineScope(Dispatchers.Default), desktopPlayerImpl, this) }
    val activeAudioDevice: StateFlow<ActiveOutputDevice> =
        MutableStateFlow(ActiveOutputDevice(PlayerOutputDevice.Unknown, PlayerOutputDevice.Unknown.defaultName))
    val eqCapabilities: StateFlow<EqCapabilities?> = MutableStateFlow(null)
    val togetherSessionState: StateFlow<TogetherSessionState> = MutableStateFlow(TogetherSessionState.Idle)
    val canvasPlaybackUseCase: CanvasPlaybackUseCase by lazy {
        androidx.hilt.navigation.compose._createViewModelInstance(CanvasPlaybackUseCase::class.java) as CanvasPlaybackUseCase
    }

    private val dummyCache: androidx.media3.datasource.cache.Cache = Proxy.newProxyInstance(
        androidx.media3.datasource.cache.Cache::class.java.classLoader,
        arrayOf(androidx.media3.datasource.cache.Cache::class.java)
    ) { _, method, _ ->
        val ret = method.returnType
        when {
            ret == Long::class.java || ret == java.lang.Long.TYPE -> 0L
            ret == Boolean::class.java || ret == java.lang.Boolean.TYPE -> false
            ret == Int::class.java || ret == java.lang.Integer.TYPE -> 0
            ret == java.util.NavigableSet::class.java || ret == java.util.Set::class.java -> java.util.TreeSet<Any>()
            else -> null
        }
    } as androidx.media3.datasource.cache.Cache

    /* Exposed to the storage/cache settings screens. */
    val playerCache: androidx.media3.datasource.cache.Cache get() = dummyCache
    val downloadCache: androidx.media3.datasource.cache.Cache get() = dummyCache

    val infiniteQueueLoading: StateFlow<Boolean> = MutableStateFlow(false)
    val queueRestoreCompleted: StateFlow<Boolean> = MutableStateFlow(true)
    val waitingForNetworkConnection: StateFlow<Boolean> = MutableStateFlow(false)

    val queueTitle: String? get() = null

    val applicationContext: Context get() = android.content.DummyContext()
    val contentResolver: ContentResolver get() = ContentResolver()
    val cacheDir: File get() = applicationContext.cacheDir
    val filesDir: File get() = applicationContext.filesDir

    fun getString(resId: Int): String = applicationContext.getString(resId)
    fun getString(resId: Int, vararg formatArgs: Any?): String = applicationContext.getString(resId, *formatArgs)

    private var currentQueue: Queue? = null
    private var isLoadingMoreQueue = false

    fun loadMoreQueueItems() {
        val q = currentQueue ?: return
        if (!q.hasNextPage() || isLoadingMoreQueue) return
        isLoadingMoreQueue = true
        CoroutineScope(Dispatchers.IO).launch {
            try {
                System.err.println("[ArchiveTune/Audio] Loading queue.nextPage()...")
                val newItems = q.nextPage()
                System.err.println("[ArchiveTune/Audio] queue.nextPage() returned ${newItems.size} items")
                if (newItems.isNotEmpty()) {
                    withContext(Dispatchers.Default) {
                        desktopPlayerImpl.addMediaItems(newItems)
                    }
                }
            } catch (t: Throwable) {
                System.err.println("[ArchiveTune/Audio] Error in queue.nextPage(): ${t.message}")
            } finally {
                isLoadingMoreQueue = false
            }
        }
    }

    // Playback / queue commands
    fun playQueue(vararg args: Any?) {
        val queue = args.firstOrNull() as? Queue ?: run {
            System.err.println("[ArchiveTune/Audio] playQueue called without Queue argument: ${args.toList()}")
            return
        }
        currentQueue = queue
        val playWhenReady = args.getOrNull(1) as? Boolean ?: true
        desktopPlayerImpl.playWhenReady = playWhenReady

        // Fast-path: if queue is ListQueue and has items
        if (queue is moe.rukamori.archivetune.playback.queues.ListQueue) {
            if (queue.items.isNotEmpty()) {
                val idx = queue.startIndex.coerceIn(queue.items.indices)
                desktopPlayerImpl.setMediaItems(queue.items, idx, queue.position)
                val meta = queue.items.getOrNull(idx)?.metadata
                if (meta != null) {
                    currentMediaMetadata.value = meta
                }
                if (playWhenReady) {
                    desktopPlayerImpl.play()
                }
                return
            }
        }

        // Fast-path: immediately set preload item or fallback from queue endpoint if present
        val preload = queue.preloadItem
        val videoId = try {
            val epField = queue.javaClass.getDeclaredField("endpoint").apply { isAccessible = true }.get(queue)
            epField?.javaClass?.getMethod("getVideoId")?.invoke(epField) as? String
        } catch (_: Throwable) {
            null
        }

        val initialMeta = preload ?: if (!videoId.isNullOrBlank()) {
            MediaMetadata(
                id = videoId,
                title = "Playing...",
                artists = emptyList(),
                duration = 0,
                thumbnailUrl = "https://i.ytimg.com/vi/$videoId/hqdefault.jpg"
            )
        } else null

        System.err.println("[ArchiveTune/Audio] playQueue: queue=${queue.javaClass.simpleName}, preload=${preload?.id}, videoId=$videoId, initialMeta=${initialMeta?.id}, playWhenReady=$playWhenReady")

        if (initialMeta != null) {
            currentMediaMetadata.value = initialMeta
            desktopPlayerImpl.setMediaItems(listOf(initialMeta.toMediaItem()), 0, 0L)
            if (playWhenReady) {
                desktopPlayerImpl.play()
            }
        }

        // Asynchronously load full queue status
        CoroutineScope(Dispatchers.IO).launch {
            try {
                System.err.println("[ArchiveTune/Audio] Loading queue.getInitialStatus()...")
                val initialStatus = queue.getInitialStatus()
                val items = initialStatus.items
                System.err.println("[ArchiveTune/Audio] Queue loaded: itemsCount=${items.size}, mediaItemIndex=${initialStatus.mediaItemIndex}")
                if (items.isNotEmpty()) {
                    withContext(Dispatchers.Default) {
                        val index = initialStatus.mediaItemIndex.coerceIn(items.indices)
                        desktopPlayerImpl.playWhenReady = playWhenReady
                        desktopPlayerImpl.setMediaItems(items, index, initialStatus.position)
                        val currentItem = items.getOrNull(index)
                        val meta = currentItem?.metadata ?: initialMeta
                        if (meta != null) {
                            currentMediaMetadata.value = meta
                        }
                        if (playWhenReady) {
                            desktopPlayerImpl.play()
                        }
                    }
                }
            } catch (e: Throwable) {
                System.err.println("[ArchiveTune/Audio] Error in queue.getInitialStatus(): ${e.message}")
                e.printStackTrace()
            }
        }
    }

    fun playNext(vararg args: Any?) {
        val items = (args.firstOrNull() as? List<*>)?.filterIsInstance<MediaItem>()
            ?: (args.firstOrNull() as? MediaItem)?.let { listOf(it) }
            ?: return
        desktopPlayerImpl.addMediaItems(desktopPlayerImpl.currentMediaItemIndex + 1, items)
    }

    fun addToQueue(vararg args: Any?) {
        val items = (args.firstOrNull() as? List<*>)?.filterIsInstance<MediaItem>()
            ?: (args.firstOrNull() as? MediaItem)?.let { listOf(it) }
            ?: return
        desktopPlayerImpl.addMediaItems(items)
    }

    fun moveQueueItemToNext(vararg args: Any?) {
        val index = args.firstOrNull() as? Int ?: return
        val currentIdx = desktopPlayerImpl.currentMediaItemIndex
        if (index != currentIdx && index in 0 until desktopPlayerImpl.mediaItemCount) {
            desktopPlayerImpl.moveMediaItem(index, currentIdx + 1)
        }
    }

    fun playFromVoiceSearch(vararg args: Any?) {}

    fun stopAndClearPlayback(clearPersistentState: Boolean = false) {
        desktopPlayerImpl.pause()
        desktopPlayerImpl.clearMediaItems()
        currentMediaMetadata.value = null
    }

    fun startRadioSeamlessly(vararg args: Any?) {
        val meta = currentMediaMetadata.value ?: return
        playQueue(moe.rukamori.archivetune.playback.queues.YouTubeQueue.radio(meta))
    }

    fun onInfiniteQueueEnabled() {}

    fun onInfiniteQueueDisabled() {}

    fun toggleLike() {
        val meta = currentMediaMetadata.value ?: return
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val db = androidx.hilt.navigation.compose.getGlobalMusicDatabase() as? moe.rukamori.archivetune.db.MusicDatabase ?: return@launch
                val existing = db.getSongById(meta.id)
                if (existing != null) {
                    db.update(existing.song.toggleLike())
                } else {
                    db.insert(meta)
                    val inserted = db.getSongById(meta.id)
                    if (inserted != null) {
                        db.update(inserted.song.toggleLike())
                    }
                }
            } catch (e: Throwable) {
                System.err.println("[ArchiveTune/Audio] toggleLike error: ${e.message}")
            }
        }
    }

    fun refreshActiveDevice() {}

    fun pauseFromSleepTimer() {}

    fun forceDiscordSync(vararg args: Any?) {}

    fun refreshDiscordNow() {}

    fun applySystemEqPreset(vararg args: Any?) {}

    fun applyEqFlatPreset() {}

    fun requestTogetherControl(vararg args: Any?) {}

    fun leaveTogether() {}

    fun transferTogetherHostOwnership(newHostId: String, newHostName: String = "") {}

    fun banTogetherParticipant(participantId: String) {}

    fun unbanTogetherParticipant(participantId: String) {}

    fun updateTogetherSettings(settings: Any?) {}

    fun approveTogetherParticipant(participantId: String, approved: Boolean) {}

    fun kickTogetherParticipant(participantId: String) {}

    fun startTogetherHost(
        port: Int = 0,
        displayName: String = "",
        settings: Any? = null,
    ) {}

    fun startTogetherOnlineHost(
        displayName: String = "",
        settings: Any? = null,
    ) {}

    fun joinTogether(vararg args: Any?) {}

    fun joinTogetherOnline(vararg args: Any?) {}

    companion object {
        const val PERSISTENT_QUEUE_FILE = "persistent_queue.data"

        const val NOTIFICATION_ID = 1001
        const val CHANNEL_ID = "archivetune_playback"
        const val ACTION_MEDIA_NOTIFICATION_DISMISSED =
            "moe.rukamori.archivetune.MEDIA_NOTIFICATION_DISMISSED"
        const val EXTRA_MEDIA_NOTIFICATION_DELETE_INTENT =
            "moe.rukamori.archivetune.EXTRA_MEDIA_NOTIFICATION_DELETE_INTENT"

        // Browse-tree ids. Only ever compared against each other, never persisted.
        const val ROOT = "root"
        const val HOME = "home"
        const val HOME_QUICK_PICKS = "home_quick_picks"
        const val HOME_SUGGESTED_SONGS = "home_suggested_songs"
        const val HOME_KEEP_LISTENING = "home_keep_listening"
        const val HOME_FORGOTTEN_FAVORITES = "home_forgotten_favorites"
        const val HOME_MIXES_AND_RADIOS = "home_mixes_and_radios"
        const val QUICK_PICKS = "quick_picks"
        const val LIBRARY = "library"
        const val PLAYLIST = "playlist"
        const val ONLINE_PLAYLIST = "online_playlist"
        const val ARTIST = "artist"
        const val ALBUM = "album"
        const val SONG = "song"
        const val LIKED = "liked"
        const val DOWNLOADED = "downloaded"
        const val RECENT = "recent"
    }
}
