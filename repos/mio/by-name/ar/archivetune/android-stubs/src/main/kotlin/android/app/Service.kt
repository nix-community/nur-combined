package android.app

import android.content.ContextWrapper
import android.content.Intent

open class Service : ContextWrapper(null) {
    open fun onCreate() {}
    open fun onDestroy() {}
    open fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = 0
    open fun onBind(intent: Intent?): android.os.IBinder? = null
    
    fun stopSelf() {}
    fun stopForeground(flags: Int) {}
    
    companion object {
        const val START_NOT_STICKY = 2
        const val START_STICKY = 1
        const val STOP_FOREGROUND_REMOVE = 1
        const val STOP_FOREGROUND_DETACH = 2
    }
}
