package android.app
open class NotificationManager {
    companion object {
        const val IMPORTANCE_DEFAULT = 3
    }
    open fun createNotificationChannel(channel: NotificationChannel) {}
}
