package coil3.request

import coil3.Image

sealed class ImageResult {
    open val image: Image? = null
}
