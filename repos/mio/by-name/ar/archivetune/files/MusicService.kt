package moe.rukamori.archivetune.playback

import android.content.ContentResolver
import android.content.Context
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
import java.io.File
import java.lang.reflect.Proxy
import java.util.concurrent.CopyOnWriteArrayList
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import moe.rukamori.archivetune.canvas.CanvasPlaybackUseCase
import moe.rukamori.archivetune.extensions.metadata
import moe.rukamori.archivetune.extensions.toMediaItem
import moe.rukamori.archivetune.models.ActiveOutputDevice
import moe.rukamori.archivetune.models.MediaMetadata
import moe.rukamori.archivetune.models.PlayerOutputDevice
import moe.rukamori.archivetune.playback.queues.Queue
import moe.rukamori.archivetune.together.TogetherSessionState

/*
 * Upstream's MusicService is an Android MediaSessionService hosting playback, bound
 * by MediaLibrarySessionCallback and updated by MusicServiceWidgetUpdater.
 *
 * For Compose Multiplatform Desktop, DesktopPlayerImpl provides full reactive
 * playback state, playlist queueing, media item transition, and play/pause controls.
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
                val dur = (item.metadata?.duration?.toLong()?.times(1000L)) ?: 0L
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

        override var playWhenReady: Boolean = false
            set(value) {
                field = value
                if (value && playbackState == Player.STATE_READY) {
                    if (!_isPlaying) {
                        _isPlaying = true
                        playStartTime = System.currentTimeMillis()
                        listeners.forEach {
                            it.onIsPlayingChanged(true)
                            it.onPlayWhenReadyChanged(true, Player.PLAY_WHEN_READY_CHANGE_REASON_USER_REQUEST)
                        }
                    }
                } else if (!value && _isPlaying) {
                    pausedPosition = currentPosition
                    _isPlaying = false
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
                playStartTime = System.currentTimeMillis()
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
            pause()
            playbackState = Player.STATE_IDLE
            listeners.forEach { it.onPlaybackStateChanged(playbackState) }
        }

        override fun release() {
            stop()
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
                    listeners.forEach {
                        it.onMediaItemTransition(item, Player.MEDIA_ITEM_TRANSITION_REASON_SEEK)
                    }
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
            }
            listeners.forEach {
                it.onTimelineChanged(_timeline, Player.TIMELINE_CHANGE_REASON_PLAYLIST_CHANGED)
                it.onMediaItemTransition(item, Player.MEDIA_ITEM_TRANSITION_REASON_PLAYLIST_CHANGED)
                it.onPlaybackStateChanged(playbackState)
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
                listeners.forEach {
                    it.onMediaItemTransition(item, Player.MEDIA_ITEM_TRANSITION_REASON_PLAYLIST_CHANGED)
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
            mediaItems.clear()
            _timeline = Timeline.EMPTY
            currentMediaItemIndex = -1
            pausedPosition = 0L
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
    val cacheDir: File get() = File("/tmp")

    fun getString(resId: Int): String = ""

    // Playback / queue commands
    fun playQueue(vararg args: Any?) {
        val queue = args.firstOrNull() as? Queue ?: return
        val playWhenReady = args.getOrNull(1) as? Boolean ?: true

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

        val initialMeta = preload ?: if (videoId != null) {
            MediaMetadata(
                id = videoId,
                title = "Playing...",
                artists = emptyList(),
                duration = 0,
                thumbnailUrl = "https://i.ytimg.com/vi/$videoId/hqdefault.jpg"
            )
        } else null

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
                val initialStatus = queue.getInitialStatus()
                val items = initialStatus.items
                if (items.isNotEmpty()) {
                    withContext(Dispatchers.Default) {
                        val index = initialStatus.mediaItemIndex.coerceIn(items.indices)
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

    fun startRadioSeamlessly(vararg args: Any?) {}

    fun onInfiniteQueueEnabled() {}

    fun onInfiniteQueueDisabled() {}

    fun toggleLike() {}

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
