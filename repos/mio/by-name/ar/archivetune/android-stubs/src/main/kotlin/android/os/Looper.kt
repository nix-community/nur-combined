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
