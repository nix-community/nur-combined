package androidx.core.app
import android.content.Context
open class NotificationManagerCompat {
    companion object {
        fun from(context: Context): NotificationManagerCompat = NotificationManagerCompat()
    }
    open fun cancel(id: Int) {}
    open fun notify(id: Int, notification: android.app.Notification) {}
    open fun createNotificationChannel(channel: android.app.NotificationChannel) {}
}
