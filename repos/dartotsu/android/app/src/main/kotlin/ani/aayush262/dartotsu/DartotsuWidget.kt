package ani.aayush262.dartotsu

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Shader
import android.net.Uri
import android.os.Build
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.io.File
import java.net.HttpURLConnection
import java.net.URL
import java.security.MessageDigest

class DartotsuWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        async { render(context, manager, ids) }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        manager: AppWidgetManager,
        id: Int,
        newOptions: android.os.Bundle,
    ) {
        async { render(context, manager, intArrayOf(id)) }
    }

    private fun async(work: () -> Unit) {
        val pending = goAsync()
        Thread {
            try {
                work()
            } catch (_: Exception) {
            } finally {
                pending.finish()
            }
        }.start()
    }

    companion object {
        private const val PREFS = "dartotsu_widget"
        private const val KEY = "payload"
        private const val CONTINUE_LINK = "dartotsu://app/continue"
        private const val COVER_W = 56
        private const val COVER_H = 80

        fun store(context: Context, json: String) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString(KEY, json).apply()
        }

        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, DartotsuWidget::class.java))
            if (ids.isNotEmpty()) render(context, manager, ids)
        }

        private fun render(context: Context, manager: AppWidgetManager, ids: IntArray) {
            val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null)
            val data = raw?.let { runCatching { JSONObject(it) }.getOrNull() }
            val covers = Covers(context)
            val small = build(context, data, covers, R.layout.widget_small, false)
            val large = build(context, data, covers, R.layout.widget_large, true)
            for (id in ids) {
                val views = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    RemoteViews(mapOf(SizeF(180f, 110f) to small, SizeF(250f, 230f) to large))
                } else {
                    val height = manager.getAppWidgetOptions(id).getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
                    if (height >= 200) large else small
                }
                manager.updateAppWidget(id, views)
            }
            manager.notifyAppWidgetViewDataChanged(ids, R.id.list)
        }

        private fun build(
            context: Context,
            data: JSONObject?,
            covers: Covers,
            layout: Int,
            withRows: Boolean,
        ): RemoteViews {
            val views = RemoteViews(context.packageName, layout)
            val current = data?.optJSONObject("continue")
            val density = context.resources.displayMetrics.density
            val radius = 12 * density
            views.setTextViewText(R.id.heading, data?.optString("heading").orEmpty())
            if (current != null) {
                views.setTextViewText(R.id.title, current.optString("title"))
                views.setTextViewText(R.id.detail, current.optString("detail"))
                views.setViewVisibility(R.id.detail, View.VISIBLE)
                views.setViewVisibility(R.id.progress, View.VISIBLE)
                views.setViewVisibility(R.id.play, View.VISIBLE)
                views.setProgressBar(R.id.progress, 100, current.optInt("progress"), false)
                covers.bitmap(current.optString("cover"), COVER_W, COVER_H, radius)
                    ?.let { views.setImageViewBitmap(R.id.cover, it) }
            } else {
                views.setTextViewText(
                    R.id.title,
                    data?.optString("empty") ?: context.getString(R.string.widget_description),
                )
                views.setViewVisibility(R.id.detail, View.GONE)
                views.setViewVisibility(R.id.progress, View.GONE)
                views.setViewVisibility(R.id.play, View.GONE)
            }
            val open = link(context, CONTINUE_LINK, 1)
            views.setOnClickPendingIntent(R.id.card, open)
            views.setOnClickPendingIntent(R.id.play, open)
            if (withRows) attachList(context, views)
            return views
        }

        private fun attachList(context: Context, views: RemoteViews) {
            val adapter = Intent(context, DartotsuWidgetService::class.java)
                .setData(Uri.parse("dartotsu-widget://list"))
            views.setRemoteAdapter(R.id.list, adapter)
            val template = Intent(Intent.ACTION_VIEW)
                .setClassName(context.packageName, "${context.packageName}.MainActivity")
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
            views.setPendingIntentTemplate(R.id.list, PendingIntent.getActivity(context, 3, template, flags))
        }

        fun payload(context: Context): JSONObject? =
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null)
                ?.let { runCatching { JSONObject(it) }.getOrNull() }

        private fun link(context: Context, uri: String, code: Int): PendingIntent {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(uri))
                .setClassName(context.packageName, "${context.packageName}.MainActivity")
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            return PendingIntent.getActivity(
                context,
                code,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
    }

    internal class Covers(private val context: Context) {
        private val cache = HashMap<String, Bitmap?>()
        private val dir = File(context.cacheDir, "widget").also { it.mkdirs() }

        fun bitmap(source: String, widthDp: Int, heightDp: Int, radius: Float): Bitmap? {
            if (source.isEmpty() || source == "null") return null
            val density = context.resources.displayMetrics.density
            val w = (widthDp * density).toInt()
            val h = (heightDp * density).toInt()
            return cache.getOrPut("$source@$w") {
                runCatching { decode(source, w, h)?.let { crop(it, w, h, radius) } }.getOrNull()
            }
        }

        private fun decode(source: String, w: Int, h: Int): Bitmap? {
            val file = if (source.startsWith("/")) File(source) else download(source) ?: return null
            if (!file.exists()) return null
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeFile(file.path, bounds)
            if (bounds.outWidth <= 0) return null
            var sample = 1
            while (bounds.outWidth / (sample * 2) >= w && bounds.outHeight / (sample * 2) >= h) sample *= 2
            return BitmapFactory.decodeFile(file.path, BitmapFactory.Options().apply { inSampleSize = sample })
        }

        private fun download(url: String): File? {
            if (!url.startsWith("http")) return null
            val name = MessageDigest.getInstance("SHA-1").digest(url.toByteArray())
                .joinToString("") { "%02x".format(it) }
            val file = File(dir, name)
            if (file.exists() && file.length() > 0) return file
            prune()
            val connection = URL(url).openConnection() as HttpURLConnection
            connection.connectTimeout = 8000
            connection.readTimeout = 8000
            return try {
                if (connection.responseCode !in 200..299) return null
                val part = File(dir, "$name.part")
                connection.inputStream.use { input -> part.outputStream().use { input.copyTo(it) } }
                if (part.renameTo(file)) file else null
            } finally {
                connection.disconnect()
            }
        }

        private fun prune() {
            val files = dir.listFiles() ?: return
            if (files.size < 40) return
            files.sortedBy { it.lastModified() }.take(files.size - 20).forEach { it.delete() }
        }

        private fun crop(source: Bitmap, w: Int, h: Int, radius: Float): Bitmap {
            val scale = maxOf(w / source.width.toFloat(), h / source.height.toFloat())
            val scaled = Bitmap.createScaledBitmap(
                source,
                (source.width * scale).toInt().coerceAtLeast(w),
                (source.height * scale).toInt().coerceAtLeast(h),
                true,
            )
            val left = (scaled.width - w) / 2
            val top = (scaled.height - h) / 2
            val out = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = BitmapShader(
                    Bitmap.createBitmap(scaled, left, top, w, h),
                    Shader.TileMode.CLAMP,
                    Shader.TileMode.CLAMP,
                )
            }
            Canvas(out).drawRoundRect(RectF(0f, 0f, w.toFloat(), h.toFloat()), radius, radius, paint)
            return out
        }
    }
}
