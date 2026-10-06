package androidx.media3.session

import com.google.common.collect.ImmutableList

/*
 * Upstream implements MediaNotification.Provider (ArchiveTuneMediaNotificationProvider) and
 * overrides handleCustomCommand / getNotificationChannelInfo, so Provider must declare both, and
 * its Callback/NotificationChannelInfo are referenced as MediaNotification.Provider.*.
 */
open class MediaNotification {
    /* Upstream rewrites the delete intent on the underlying Android notification. */
    open val notification: android.app.Notification = android.app.Notification()

    open val notificationId: Int = 0

    interface Provider {
        fun createNotification(
            mediaSession: MediaSession,
            mediaButtonPreferences: ImmutableList<CommandButton>,
            actionFactory: ActionFactory,
            onNotificationChangedCallback: Callback,
        ): MediaNotification = MediaNotification()

        fun handleCustomCommand(
            session: MediaSession,
            action: String,
            extras: android.os.Bundle,
        ): Boolean = false

        fun getNotificationChannelInfo(): NotificationChannelInfo = NotificationChannelInfo()

        fun onUpdateNotification(
            session: MediaSession,
            startInForegroundRequired: Boolean,
        ) {}

        fun onNotificationCancelled(notificationId: Int, dismissedByUser: Boolean) {}

        /** Referred to as MediaNotification.Provider.Callback. */
        interface Callback {
            fun onNotificationChanged(notification: MediaNotification) {}
        }

        /** Referred to as MediaNotification.Provider.NotificationChannelInfo. */
        class NotificationChannelInfo(
            val channelId: String = "",
            val channelNameResourceId: Int = 0,
            val channelDescriptionResourceId: Int = 0,
        )
    }

    fun interface ActionFactory {
        fun createMediaAction(
            mediaSession: MediaSession,
            button: CommandButton,
        ): Any
    }

    companion object { }
}
