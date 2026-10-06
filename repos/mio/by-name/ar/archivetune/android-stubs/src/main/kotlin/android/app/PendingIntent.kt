package android.app

import android.content.Context
import android.content.Intent

open class PendingIntent {
    companion object {
        @JvmStatic
        fun getService(
            context: android.content.Context?,
            requestCode: Int,
            intent: android.content.Intent,
            flags: Int,
        ): PendingIntent = PendingIntent()

        @JvmStatic
        fun getActivity(
            context: android.content.Context?,
            requestCode: Int,
            intent: android.content.Intent,
            flags: Int,
        ): PendingIntent = PendingIntent()

        @JvmStatic
        fun getBroadcast(
            context: android.content.Context?,
            requestCode: Int,
            intent: android.content.Intent,
            flags: Int,
        ): PendingIntent = PendingIntent()

        const val FLAG_UPDATE_CURRENT = 1
        const val FLAG_IMMUTABLE = 2
    }
}
