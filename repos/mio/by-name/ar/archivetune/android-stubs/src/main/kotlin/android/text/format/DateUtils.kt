package android.text.format

import android.content.Context
import java.util.Locale

object DateUtils {
    const val SECOND_IN_MILLIS = 1000L
    const val MINUTE_IN_MILLIS = 60 * SECOND_IN_MILLIS
    const val HOUR_IN_MILLIS = 60 * MINUTE_IN_MILLIS
    const val DAY_IN_MILLIS = 24 * HOUR_IN_MILLIS
    const val WEEK_IN_MILLIS = 7 * DAY_IN_MILLIS
    const val YEAR_IN_MILLIS = 365 * DAY_IN_MILLIS

    @JvmStatic
    fun formatElapsedTime(elapsedSeconds: Long): String {
        val minutes = elapsedSeconds / 60
        val seconds = elapsedSeconds % 60
        return "%02d:%02d".format(minutes, seconds)
    }
}

object DateFormat {
    @JvmStatic
    fun is24HourFormat(context: Context?): Boolean = true
}

object Formatter {
    @JvmStatic
    fun formatFileSize(context: Context?, sizeBytes: Long): String {
        if (sizeBytes <= 0) return "0 B"
        val units = arrayOf("B", "KB", "MB", "GB", "TB")
        val digitGroups = (Math.log10(sizeBytes.toDouble()) / Math.log10(1024.0)).toInt().coerceIn(0, units.size - 1)
        val value = sizeBytes / Math.pow(1024.0, digitGroups.toDouble())
        return String.format(Locale.US, "%.1f %s", value, units[digitGroups])
    }

    @JvmStatic
    fun formatShortFileSize(context: Context?, sizeBytes: Long): String = formatFileSize(context, sizeBytes)
}
