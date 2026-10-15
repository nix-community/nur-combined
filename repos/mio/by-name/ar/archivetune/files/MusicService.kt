package moe.rukamori.archivetune.playback

import android.content.ContentResolver
import android.content.Context
import androidx.media3.common.PlaybackParameters
import androidx.media3.common.Player
import androidx.media3.common.Timeline
import androidx.media3.common.Tracks
import java.io.File
import java.lang.reflect.Proxy
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import moe.rukamori.archivetune.canvas.CanvasPlaybackUseCase
import moe.rukamori.archivetune.models.ActiveOutputDevice
import moe.rukamori.archivetune.models.MediaMetadata
import moe.rukamori.archivetune.models.PlayerOutputDevice
import moe.rukamori.archivetune.together.TogetherSessionState

/*
 * Upstream's MusicService is an Android MediaSessionService hosting playback, bound
 * by MediaLibrarySessionCallback and updated by MusicServiceWidgetUpdater. None of
 * that has a meaning on the JVM desktop: there is no Service to bind, no
 * MediaSession, and no QS/widget surface.
 *
 * The port keeps the type surface the rest of the app resolves against (browse-tree
 * ids, the binder, and the service state the view models observe).
 */
class MusicService {
    class MusicBinder internal constructor(val service: MusicService)

    /*
     * Upstream reads `player.currentMetadata` as the app's own MediaMetadata model (media3's
     * Player declares it as media3's MediaMetadata instead). Declaring it here rather than on
     * the android-stubs fake keeps android-stubs independent of :app's models package.
     */
    interface DesktopPlayer : Player {
        val currentMetadata: MediaMetadata?
    }

    private val dummyPlayer: DesktopPlayer = Proxy.newProxyInstance(
        DesktopPlayer::class.java.classLoader,
        arrayOf(DesktopPlayer::class.java)
    ) { _, method, _ ->
        when (method.name) {
            "getCurrentMetadata" -> null
            "getPlaybackState" -> Player.STATE_IDLE
            "isPlaying" -> false
            "getPlaybackParameters" -> PlaybackParameters.DEFAULT
            "getCurrentTimeline" -> Timeline.EMPTY
            "getMediaItemCount" -> 0
            "getCurrentMediaItemIndex" -> -1
            "getShuffleModeEnabled" -> false
            "getRepeatMode" -> Player.REPEAT_MODE_OFF
            "getCurrentPosition" -> 0L
            "getDuration" -> 0L
            "getCurrentTracks" -> Tracks.EMPTY
            else -> {
                val ret = method.returnType
                when {
                    ret == Boolean::class.java || ret == java.lang.Boolean.TYPE -> false
                    ret == Int::class.java || ret == java.lang.Integer.TYPE -> 0
                    ret == Long::class.java || ret == java.lang.Long.TYPE -> 0L
                    ret == Float::class.java || ret == java.lang.Float.TYPE -> 0f
                    ret == Double::class.java || ret == java.lang.Double.TYPE -> 0.0
                    ret == String::class.java -> ""
                    else -> null
                }
            }
        }
    } as DesktopPlayer

    val player: DesktopPlayer get() = dummyPlayer
    val localPlayer: DesktopPlayer get() = dummyPlayer

    val currentMediaMetadata = MutableStateFlow<MediaMetadata?>(null)
    val sleepTimer by lazy { SleepTimer(CoroutineScope(Dispatchers.Default), dummyPlayer, this) }
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

    // Playback / queue commands. Inert on desktop; loose signatures keep upstream
    // call sites resolving while the desktop playback layer does not exist yet.
    fun playQueue(vararg args: Any?) {}

    fun playNext(vararg args: Any?) {}

    fun addToQueue(vararg args: Any?) {}

    fun moveQueueItemToNext(vararg args: Any?) {}

    fun playFromVoiceSearch(vararg args: Any?) {}

    fun stopAndClearPlayback(clearPersistentState: Boolean = false) {}

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
