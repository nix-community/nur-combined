
package ani.aayush262.dartotsu

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONObject

class DartotsuWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory = Factory(applicationContext)

    private class Item(
        val type: Int,
        val title: String,
        val detail: String = "",
        val cover: String = "",
        val progress: Int = 0,
        val link: String = "",
    )

    private class Factory(private val context: Context) : RemoteViewsFactory {
        private var items: List<Item> = emptyList()
        private var covers: DartotsuWidget.Covers? = null

        override fun onCreate() {}

        override fun onDataSetChanged() {
            covers = DartotsuWidget.Covers(context)
            val data = DartotsuWidget.payload(context)
            items = if (data == null) emptyList() else parse(data)
        }

        private fun parse(data: JSONObject): List<Item> {
            val out = ArrayList<Item>()
            val resume = data.optJSONArray("resume")
            if (resume != null && resume.length() > 0) {
                out.add(Item(HEADING, data.optString("moreHeading")))
                for (i in 0 until resume.length()) {
                    val e = resume.getJSONObject(i)
                    out.add(
                        Item(
                            RESUME,
                            e.optString("title"),
                            e.optString("detail"),
                            e.optString("cover"),
                            e.optInt("progress"),
                            "$CONTINUE?slot=${Uri.encode(e.optString("slot"))}",
                        ),
                    )
                }
            }
            val releases = data.optJSONArray("releases")
            if (releases != null && releases.length() > 0) {
                out.add(Item(HEADING, data.optString("releasesHeading")))
                for (i in 0 until releases.length()) {
                    val e = releases.getJSONObject(i)
                    out.add(
                        Item(
                            RELEASE,
                            e.optString("title"),
                            e.optString("detail"),
                            e.optString("cover"),
                            link = CALENDAR,
                        ),
                    )
                }
            }
            return out
        }

        override fun getCount() = items.size

        override fun getViewAt(position: Int): RemoteViews {
            val item = items.getOrNull(position) ?: return RemoteViews(context.packageName, R.layout.widget_item_heading)
            val density = context.resources.displayMetrics.density
            val views = when (item.type) {
                HEADING -> RemoteViews(context.packageName, R.layout.widget_item_heading).also {
                    it.setTextViewText(R.id.itemHeading, item.title)
                }
                RESUME -> RemoteViews(context.packageName, R.layout.widget_item_resume).also {
                    it.setTextViewText(R.id.itemTitle, item.title)
                    it.setTextViewText(R.id.itemDetail, item.detail)
                    it.setProgressBar(R.id.itemProgress, 100, item.progress, false)
                    covers?.bitmap(item.cover, 40, 56, 10 * density)?.let { b -> it.setImageViewBitmap(R.id.itemCover, b) }
                    it.setOnClickFillInIntent(R.id.item, Intent().setData(Uri.parse(item.link)))
                }
                else -> RemoteViews(context.packageName, R.layout.widget_row).also {
                    it.setTextViewText(R.id.rowTitle, item.title)
                    it.setTextViewText(R.id.rowDetail, item.detail)
                    covers?.bitmap(item.cover, 36, 36, 10 * density)?.let { b -> it.setImageViewBitmap(R.id.rowCover, b) }
                    it.setOnClickFillInIntent(R.id.row, Intent().setData(Uri.parse(item.link)))
                }
            }
            return views
        }

        override fun getLoadingView(): RemoteViews? = null

        override fun getViewTypeCount() = 3

        override fun getItemId(position: Int) = position.toLong()

        override fun hasStableIds() = false

        override fun onDestroy() {
            items = emptyList()
        }
    }

    private companion object {
        const val HEADING = 0
        const val RESUME = 1
        const val RELEASE = 2
        const val CONTINUE = "dartotsu://app/continue"
        const val CALENDAR = "dartotsu://app/calendar?service=extension"
    }
}
