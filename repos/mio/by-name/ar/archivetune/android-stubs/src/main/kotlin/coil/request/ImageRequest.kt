package coil.request

import android.content.Context

open class ImageRequest {
    open class Builder(context: Context) {
        fun data(data: Any?): Builder = this
        fun size(size: Int): Builder = this
        fun build(): ImageRequest = ImageRequest()
    }
}
