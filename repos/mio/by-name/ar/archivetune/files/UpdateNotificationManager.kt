package moe.rukamori.archivetune.utils

import android.content.Context

object UpdateNotificationManager {
    fun createNotificationChannel(context: Context) {}
    fun schedulePeriodicUpdateCheck(context: Context) {}
    suspend fun notifyIfNewVersion(
        context: Context,
        newVersion: String,
        updateChannel: Any? = null,
        releaseNotes: String? = null,
    ) {}
}
