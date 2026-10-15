package android.app

import android.content.Context
import android.content.Intent
import android.graphics.drawable.Drawable
import android.view.Window

open class Activity : android.content.ContextWrapper(null) {
    val window: Window = Window()

    open fun finish() {}
    open fun recreate() {}
    override fun startActivity(intent: Intent) {}
    open fun startActivityForResult(intent: Intent, requestCode: Int) {}
}

open class Application : android.content.ContextWrapper(null) {
    open fun onCreate() {}
    open fun onTrimMemory(level: Int) {}

    companion object {
        @JvmStatic
        fun getProcessName(): String = "moe.rukamori.archivetune"
    }
}

open class ActivityManager {
    open class MemoryInfo {
        var availMem: Long = 1024L * 1024L * 1024L * 4L
        var totalMem: Long = 1024L * 1024L * 1024L * 8L
        var lowMemory: Boolean = false
    }

    open class RunningAppProcessInfo {
        var processName: String = "moe.rukamori.archivetune"
        var pid: Int = 0
    }

    val runningAppProcesses: List<RunningAppProcessInfo> = listOf(RunningAppProcessInfo())
    open val isLowRamDevice: Boolean get() = false

    open fun getMemoryInfo(outInfo: MemoryInfo) {
        outInfo.availMem = 1024L * 1024L * 1024L * 4L
        outInfo.totalMem = 1024L * 1024L * 1024L * 8L
        outInfo.lowMemory = false
    }
}

open class Notification {
    var deleteIntent: PendingIntent? = null
    var contentIntent: PendingIntent? = null

    open class Builder(val context: Context, val channelId: String = "") {
        fun setSmallIcon(icon: Int): Builder = this
        fun setContentTitle(title: CharSequence?): Builder = this
        fun setContentText(text: CharSequence?): Builder = this
        fun setProgress(max: Int, progress: Int, indeterminate: Boolean): Builder = this
        fun setOngoing(ongoing: Boolean): Builder = this
        fun setShowWhen(show: Boolean): Builder = this
        fun addAction(action: Action): Builder = this
        fun setContentIntent(intent: PendingIntent?): Builder = this
        fun setDeleteIntent(intent: PendingIntent?): Builder = this
        fun setAutoCancel(autoCancel: Boolean): Builder = this
        fun build(): Notification = Notification()
    }

    open class Action {
        open class Builder(val icon: Any?, val title: CharSequence?, val intent: PendingIntent?) {
            fun build(): Action = Action()
        }
    }
}

open class SearchManager {
    companion object {
        const val QUERY = "query"
        const val USER_QUERY = "user_query"
    }
}

open class WallpaperManager {
    companion object {
        private val instance = WallpaperManager()
        @JvmStatic
        fun getInstance(context: Context): WallpaperManager = instance
    }

    open fun getDrawable(): Drawable? = null
}
