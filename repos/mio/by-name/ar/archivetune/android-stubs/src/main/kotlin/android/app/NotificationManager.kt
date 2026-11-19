package android.app
open class NotificationManager {
    companion object {
        const val IMPORTANCE_NONE = 0
        const val IMPORTANCE_MIN = 1
        const val IMPORTANCE_LOW = 2
        const val IMPORTANCE_DEFAULT = 3
        const val IMPORTANCE_HIGH = 4
    }
    open fun createNotificationChannel(channel: NotificationChannel) {}

    open fun getNotificationChannel(channelId: String): NotificationChannel? = null
}
