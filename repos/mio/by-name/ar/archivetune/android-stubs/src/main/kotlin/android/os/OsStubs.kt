package android.os

open class Looper private constructor(val thread: Thread) {
    companion object {
        private val mainLooperInstance = Looper(Thread.currentThread())

        @JvmStatic
        fun getMainLooper(): Looper = mainLooperInstance

        @JvmStatic
        fun myLooper(): Looper? = if (Thread.currentThread() == mainLooperInstance.thread) mainLooperInstance else null

        @JvmStatic
        fun prepareMainLooper() {}

        @JvmStatic
        fun prepare() {}

        @JvmStatic
        fun loop() {}
    }

    open fun quit() {}
    open fun quitSafely() {}
}

open class Handler(val looper: Looper = Looper.getMainLooper()) {
    open fun post(r: Runnable): Boolean {
        java.awt.EventQueue.invokeLater(r)
        return true
    }

    open fun postDelayed(r: Runnable, delayMillis: Long): Boolean {
        val timer = java.util.Timer(true)
        timer.schedule(object : java.util.TimerTask() {
            override fun run() {
                java.awt.EventQueue.invokeLater(r)
            }
        }, delayMillis)
        return true
    }

    open fun removeCallbacks(r: Runnable) {}
    open fun removeCallbacksAndMessages(token: Any?) {}
    open fun sendMessage(msg: Message): Boolean = true
    open fun obtainMessage(what: Int, obj: Any?): Message = Message().apply { this.what = what; this.obj = obj }
}

class Message {
    var what: Int = 0
    var arg1: Int = 0
    var arg2: Int = 0
    var obj: Any? = null
    fun sendToTarget() {}
}

object Process {
    @JvmStatic
    fun myPid(): Int = 0
    @JvmStatic
    fun myUid(): Int = 0
    @JvmStatic
    fun killProcess(pid: Int) {}
}

object SystemClock {
    @JvmStatic
    fun elapsedRealtime(): Long = System.currentTimeMillis()
    @JvmStatic
    fun uptimeMillis(): Long = System.currentTimeMillis()
}

class BatteryManager
class PowerManager
object Environment {
    @JvmStatic
    fun getExternalStorageDirectory(): java.io.File = java.io.File(System.getProperty("user.home", "/tmp"))
}
