package android.media

import android.content.Context
import android.net.Uri
import android.os.Handler
import java.io.FileDescriptor
import java.io.InputStream

open class AudioManager {
    companion object {
        const val STREAM_VOICE_CALL = 0
        const val STREAM_SYSTEM = 1
        const val STREAM_RING = 2
        const val STREAM_MUSIC = 3
        const val STREAM_ALARM = 4
        const val STREAM_NOTIFICATION = 5
        const val FLAG_SHOW_UI = 1
        const val FLAG_ALLOW_RINGER_MODES = 2
        const val FLAG_PLAY_SOUND = 4
        const val FLAG_REMOVE_SOUND_AND_VIBRATE = 8
        const val FLAG_VIBRATE = 16
        const val AUDIOFOCUS_GAIN = 1
        const val AUDIOFOCUS_LOSS = -1
        const val AUDIOFOCUS_LOSS_TRANSIENT = -2
        const val AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK = -3
        const val AUDIOFOCUS_REQUEST_GRANTED = 1
        const val AUDIOFOCUS_REQUEST_FAILED = 0
        const val GET_DEVICES_INPUTS = 1
        const val GET_DEVICES_OUTPUTS = 2
        const val GET_DEVICES_ALL = 3
    }

    open fun getStreamVolume(streamType: Int): Int = 10
    open fun getStreamMaxVolume(streamType: Int): Int = 15
    open fun getStreamMinVolume(streamType: Int): Int = 0
    open fun setStreamVolume(streamType: Int, index: Int, flags: Int) {}
    open fun isVolumeFixed(): Boolean = false
    open fun isMusicActive(): Boolean = false
    open fun registerAudioDeviceCallback(callback: AudioDeviceCallback, handler: Handler?) {}
    open fun unregisterAudioDeviceCallback(callback: AudioDeviceCallback) {}
    open fun getDevices(flags: Int): Array<AudioDeviceInfo> = emptyArray()
    open fun getAudioDevicesForAttributes(attributes: AudioAttributes): List<AudioDeviceInfo> = emptyList()
}

abstract class AudioDeviceCallback {
    open fun onAudioDevicesAdded(addedDevices: Array<AudioDeviceInfo>) {}
    open fun onAudioDevicesRemoved(removedDevices: Array<AudioDeviceInfo>) {}
}

open class AudioDeviceInfo {
    open val id: Int = 0
    open val productName: CharSequence = "Desktop Audio"
    open val type: Int = TYPE_BUILTIN_SPEAKER
    open val isSink: Boolean get() = true
    open val isSource: Boolean get() = false

    companion object {
        const val TYPE_UNKNOWN = 0
        const val TYPE_BUILTIN_EARPIECE = 1
        const val TYPE_BUILTIN_SPEAKER = 2
        const val TYPE_WIRED_HEADSET = 3
        const val TYPE_WIRED_HEADPHONES = 4
        const val TYPE_BLUETOOTH_SCO = 7
        const val TYPE_BLUETOOTH_A2DP = 8
        const val TYPE_USB_DEVICE = 11
        const val TYPE_USB_ACCESSORY = 12
        const val TYPE_USB_HEADSET = 22
        const val TYPE_BLE_HEADSET = 26
        const val TYPE_BLE_SPEAKER = 27
        const val TYPE_HEARING_AID = 23
        const val TYPE_HDMI = 9
        const val TYPE_HDMI_ARC = 10
        const val TYPE_HDMI_EARC = 29
        const val TYPE_BUILTIN_SPEAKER_SAFE = 24
        const val GET_DEVICES_OUTPUTS = 2
        const val GET_DEVICES_INPUTS = 1
    }
}

open class AudioAttributes {
    open class Builder {
        fun setUsage(usage: Int): Builder = this
        fun setContentType(contentType: Int): Builder = this
        fun build(): AudioAttributes = AudioAttributes()
    }

    companion object {
        const val USAGE_MEDIA = 1
        const val CONTENT_TYPE_MUSIC = 2
    }
}

open class MediaRouter2 {
    open fun showSystemOutputSwitcher(): Boolean = false

    companion object {
        private val instance = MediaRouter2()
        @JvmStatic
        fun getInstance(context: Context): MediaRouter2 = instance
    }
}

open class MediaExtractor {
    fun setDataSource(path: String) {}
    fun setDataSource(context: Context, uri: Uri, headers: Map<String, String>?) {}
    fun setDataSource(fd: FileDescriptor) {}
    val trackCount: Int get() = 0
    fun getTrackFormat(index: Int): MediaFormat = MediaFormat()
    fun selectTrack(index: Int) {}
    fun unselectTrack(index: Int) {}
    fun release() {}
}

open class MediaFormat {
    private val stringMap = mutableMapOf<String, String>()
    private val intMap = mutableMapOf<String, Int>()
    private val longMap = mutableMapOf<String, Long>()

    fun getString(name: String): String? = stringMap[name]
    fun getInteger(name: String): Int = intMap[name] ?: 0
    fun getLong(name: String): Long = longMap[name] ?: 0L
    fun containsKey(name: String): Boolean = stringMap.containsKey(name) || intMap.containsKey(name) || longMap.containsKey(name)

    fun setString(name: String, value: String) { stringMap[name] = value }
    fun setInteger(name: String, value: Int) { intMap[name] = value }
    fun setLong(name: String, value: Long) { longMap[name] = value }

    companion object {
        const val KEY_MIME = "mime"
        const val KEY_DURATION = "durationUs"
        const val KEY_BIT_RATE = "bitrate"
        const val KEY_SAMPLE_RATE = "sample-rate"
        const val KEY_CHANNEL_COUNT = "channel-count"
        const val KEY_WIDTH = "width"
        const val KEY_HEIGHT = "height"
    }
}

open class MediaCodecList(val kind: Int) {
    open fun findDecoderForFormat(format: MediaFormat): String? = "video/decoder"

    companion object {
        const val REGULAR_CODECS = 0
        const val ALL_CODECS = 1
    }
}

open class ExifInterface {
    constructor(filename: String)
    constructor(stream: InputStream)
    constructor(file: java.io.File)
    constructor(fileDescriptor: FileDescriptor)

    fun getAttribute(tag: String): String? = null
    fun getAttributeInt(tag: String, defaultValue: Int): Int = defaultValue

    companion object {
        const val TAG_ORIENTATION = "Orientation"
        const val ORIENTATION_UNDEFINED = 0
        const val ORIENTATION_NORMAL = 1
        const val ORIENTATION_FLIP_HORIZONTAL = 2
        const val ORIENTATION_ROTATE_180 = 3
        const val ORIENTATION_FLIP_VERTICAL = 4
        const val ORIENTATION_TRANSPOSE = 5
        const val ORIENTATION_ROTATE_90 = 6
        const val ORIENTATION_TRANSVERSE = 7
        const val ORIENTATION_ROTATE_270 = 8
    }
}
