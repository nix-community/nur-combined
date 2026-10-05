package androidx.core.content

import android.content.Context
import android.content.Intent

object ContextCompat {
    @JvmStatic
    fun startForegroundService(context: Context, intent: Intent) {}
    
    @JvmStatic
    fun getSystemService(context: Context, serviceClass: Class<*>): Any? = null
    
    @JvmStatic
    fun checkSelfPermission(context: Context, permission: String): Int = 0
}
