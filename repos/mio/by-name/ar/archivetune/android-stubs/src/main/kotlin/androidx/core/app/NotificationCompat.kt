package androidx.core.app

import android.app.Notification
import android.content.Context

open class NotificationCompat {
    open class Builder(context: Context, channelId: String) {
        open fun setSmallIcon(icon: Int): Builder = this
        open fun setContentTitle(title: CharSequence): Builder = this
        open fun setContentText(text: CharSequence): Builder = this
        open fun setPriority(pri: Int): Builder = this
        open fun setContentIntent(intent: android.app.PendingIntent): Builder = this
        open fun setAutoCancel(autoCancel: Boolean): Builder = this
        open fun addAction(icon: Int, title: CharSequence, intent: android.app.PendingIntent): Builder = this
        open fun build(): Notification = Notification()
    }
    companion object {
        const val PRIORITY_DEFAULT = 0
    }
}
