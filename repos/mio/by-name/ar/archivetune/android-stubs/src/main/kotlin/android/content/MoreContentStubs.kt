package android.content

import android.os.IBinder

class ActivityNotFoundException(msg: String? = null) : RuntimeException(msg)

class ContentValues {
    private val values = mutableMapOf<String, Any?>()

    fun put(key: String, value: String?) {
        values[key] = value
    }

    fun put(key: String, value: Int?) {
        values[key] = value
    }

    fun put(key: String, value: Long?) {
        values[key] = value
    }

    fun put(key: String, value: Boolean?) {
        values[key] = value
    }

    fun put(key: String, value: Float?) {
        values[key] = value
    }

    fun put(key: String, value: Double?) {
        values[key] = value
    }

    fun put(key: String, value: ByteArray?) {
        values[key] = value
    }

    fun putNull(key: String) {
        values[key] = null
    }

    fun get(key: String): Any? = values[key]
    fun getAsString(key: String): String? = values[key]?.toString()
    fun getAsInteger(key: String): Int? = values[key] as? Int
    fun getAsLong(key: String): Long? = values[key] as? Long
    fun getAsBoolean(key: String): Boolean? = values[key] as? Boolean
    fun size(): Int = values.size
    fun clear() { values.clear() }
}

abstract class BroadcastReceiver {
    abstract fun onReceive(context: Context, intent: Intent)
}

open class IntentFilter {
    constructor()
    constructor(action: String) {
        addAction(action)
    }

    private val actions = mutableListOf<String>()

    fun addAction(action: String) {
        actions.add(action)
    }

    fun hasAction(action: String): Boolean = actions.contains(action)
}

interface ServiceConnection {
    fun onServiceConnected(name: ComponentName?, service: IBinder?)
    fun onServiceDisconnected(name: ComponentName?)
}
