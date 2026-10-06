package androidx.media3.common.util

/* media3's NotificationUtil; upstream posts notifications through setNotification. */
open class NotificationUtil {
    companion object {
        @JvmStatic
        fun setNotification(
            context: Any?,
            notificationId: Int,
            notification: Any?,
        ) {}

        @JvmStatic
        fun setNotification(
            context: Any?,
            notificationId: Int,
            notification: Any?,
            foregroundServiceNotificationId: Int,
        ) {}

        @JvmStatic
        fun createNotificationChannel(context: Any?, channelId: String?, channelName: Int) {}

        @JvmStatic
        fun createNotificationChannel(
            context: Any?,
            channelId: String?,
            channelName: Int,
            channelDescriptionId: Int,
        ) {}

        @JvmStatic
        fun getNotificationChannelId(context: Any?): String? = null
    }
}
