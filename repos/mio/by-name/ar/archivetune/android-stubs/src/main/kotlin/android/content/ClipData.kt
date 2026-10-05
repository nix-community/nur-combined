package android.content

class ClipData {
    constructor(description: ClipDescription, item: Item)
    class Item {
        constructor(uri: android.net.Uri)
        constructor(text: CharSequence)
    }
    companion object {
        fun newUri(resolver: android.content.ContentResolver, label: CharSequence?, uri: android.net.Uri) = ClipData(ClipDescription(), Item(uri))
        fun newPlainText(label: CharSequence?, text: CharSequence?) = ClipData(ClipDescription(), Item(text ?: ""))
    }
}
class ClipDescription
