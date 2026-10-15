package android.os

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
}
