package coil3.request

import coil3.Image

open class SuccessResult(
    override val image: Image,
    open val request: ImageRequest
) : ImageResult()
