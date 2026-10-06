package androidx.media3.session

import android.content.Context
import com.google.common.collect.ImmutableList

/*
 * Upstream constructs this as
 * DefaultMediaNotificationProvider(context, { NOTIFICATION_ID }, CHANNEL_ID, R.string.music_player)
 * and then calls setSmallIcon(...), so the constructor and that setter must exist.
 */
open class DefaultMediaNotificationProvider(
    val context: Context? = null,
    val notificationIdProvider: () -> Int = { 0 },
    val channelId: String = "",
    val channelNameResourceId: Int = 0,
    val channelDescriptionResourceId: Int = 0,
) {
    open fun setSmallIcon(smallIconResourceId: Int) {}

    open fun setChannelNameResourceId(channelNameResourceId: Int) {}

    open fun setChannelDescriptionResourceId(channelDescriptionResourceId: Int) {}

    open fun setNotificationIdProvider(provider: () -> Int) {}

    open fun handleCustomCommand(
        session: MediaSession,
        action: String,
        extras: android.os.Bundle,
    ): Boolean = false

    open val notificationChannelInfo: MediaNotification.Provider.NotificationChannelInfo
        get() = MediaNotification.Provider.NotificationChannelInfo()

    open fun createNotification(
        mediaSession: MediaSession,
        mediaButtonPreferences: ImmutableList<CommandButton>,
        actionFactory: MediaNotification.ActionFactory,
        onNotificationChangedCallback: MediaNotification.Provider.Callback,
    ): MediaNotification = MediaNotification()

    companion object { }
}
