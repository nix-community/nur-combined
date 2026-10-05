package coil3.request

import coil3.Image

open class ErrorResult(
    override val image: Image?,
    open val request: ImageRequest,
    open val throwable: Throwable
) : ImageResult()
