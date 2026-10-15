package android.database

import android.net.Uri
import android.os.Handler

open class ContentObserver(val handler: Handler?) {
    open fun onChange(selfChange: Boolean) {}
    open fun onChange(selfChange: Boolean, uri: Uri?) {
        onChange(selfChange)
    }
}
