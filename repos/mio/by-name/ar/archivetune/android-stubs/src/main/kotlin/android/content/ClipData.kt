package android.content

class ClipData(val description: ClipDescription, val item: Item) {
    val itemCount: Int get() = 1
    fun getItemAt(index: Int): Item = item

    class Item {
        val uri: android.net.Uri?
        val text: CharSequence?

        constructor(uri: android.net.Uri) {
            this.uri = uri
            this.text = uri.toString()
        }
        constructor(text: CharSequence) {
            this.uri = null
            this.text = text
        }
    }
    companion object {
        fun newUri(resolver: android.content.ContentResolver, label: CharSequence?, uri: android.net.Uri) = ClipData(ClipDescription(), Item(uri))
        fun newRawUri(label: CharSequence?, uri: android.net.Uri) = ClipData(ClipDescription(), Item(uri))
        fun newHtmlText(label: CharSequence?, text: CharSequence?, htmlText: String?) = ClipData(ClipDescription(), Item(text ?: ""))
        fun newPlainText(label: CharSequence?, text: CharSequence?) = ClipData(ClipDescription(), Item(text ?: ""))
    }
}
class ClipDescription
