package android.os

open class Looper private constructor(private val explicitThread: Thread? = null) {
    open val thread: Thread
        get() = explicitThread ?: Thread.getAllStackTraces().keys.firstOrNull { it.name == "main" || it.name.startsWith("AWT-EventQueue") } ?: Thread.currentThread()

    companion object {
        private val mainLooperInstance = Looper()
        private val threadLocalLooper = ThreadLocal<Looper>()

        @JvmStatic
        fun getMainLooper(): Looper = mainLooperInstance

        @JvmStatic
        fun myLooper(): Looper? {
            if (java.awt.EventQueue.isDispatchThread() || Thread.currentThread() == getMainLooper().thread) {
                return mainLooperInstance
            }
            return threadLocalLooper.get()
        }

        @JvmStatic
        fun prepareMainLooper() {}

        @JvmStatic
        fun prepare() {
            if (threadLocalLooper.get() == null) {
                threadLocalLooper.set(Looper(Thread.currentThread()))
            }
        }

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
    open fun sendMessage(msg: Message): Boolean {
        msg.callback?.let { post(it) }
        return true
    }
    open fun obtainMessage(): Message = Message().apply { this.target = this@Handler }
    open fun obtainMessage(what: Int): Message = Message().apply { this.target = this@Handler; this.what = what }
    open fun obtainMessage(what: Int, obj: Any?): Message = Message().apply { this.target = this@Handler; this.what = what; this.obj = obj }
}

class Message {
    var what: Int = 0
    var arg1: Int = 0
    var arg2: Int = 0
    var obj: Any? = null
    var target: Handler? = null
    var callback: Runnable? = null
    fun sendToTarget() {
        target?.sendMessage(this)
    }
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
