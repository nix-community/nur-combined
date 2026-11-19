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

    const val FORMAT_SHOW_DATE = 0x10
    const val FORMAT_SHOW_TIME = 0x01

    @JvmStatic
    fun getRelativeTimeSpanString(millis: Long): String {
        val delta = System.currentTimeMillis() - millis
        return when {
            delta < MINUTE_IN_MILLIS -> "just now"
            delta < HOUR_IN_MILLIS -> "${delta / MINUTE_IN_MILLIS} min ago"
            delta < DAY_IN_MILLIS -> "${delta / HOUR_IN_MILLIS} h ago"
            else -> "${delta / DAY_IN_MILLIS} d ago"
        }
    }

    @JvmStatic
    fun getBestDateTimePattern(locale: Locale?, skeleton: String?): String = "MMM d, yyyy"

    @JvmStatic
    fun getRelativeTimeSpanString(begin: Long, end: Long, flags: Long): CharSequence =
        getRelativeTimeSpanString(begin)

    @JvmStatic
    fun formatDateTime(context: Context?, millis: Long, flags: Int): String =
        java.text.SimpleDateFormat("MMM d, yyyy HH:mm", Locale.getDefault()).format(java.util.Date(millis))

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

    @JvmStatic
    fun getMediumDateFormat(context: Context?): java.text.DateFormat =
        java.text.SimpleDateFormat("MMM d, yyyy", Locale.getDefault())

    @JvmStatic
    fun getDateFormat(context: Context?): java.text.DateFormat =
        java.text.SimpleDateFormat("MMM d, yyyy", Locale.getDefault())

    @JvmStatic
    fun formatDateTime(context: Context?, millis: Long, flags: Int): String =
        java.text.SimpleDateFormat("MMM d, yyyy HH:mm", Locale.getDefault()).format(java.util.Date(millis))

    @JvmStatic
    fun getBestDateTimePattern(locale: Locale?, skeleton: String?): String = "MMM d, yyyy"

    @JvmStatic
    fun getTimeFormat(context: Context?): java.text.DateFormat =
        java.text.SimpleDateFormat(if (is24HourFormat(context)) "HH:mm" else "h:mm a", Locale.getDefault())
}

object DateFormatFlags {
    const val FORMAT_SHOW_DATE = 0x10
    const val FORMAT_SHOW_TIME = 0x01
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
