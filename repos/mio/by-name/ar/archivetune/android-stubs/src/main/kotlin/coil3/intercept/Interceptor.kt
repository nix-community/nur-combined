package coil3.intercept

import coil3.request.ImageRequest
import coil3.request.ImageResult

interface Interceptor {
    suspend fun intercept(chain: Chain): ImageResult

    interface Chain {
        val request: ImageRequest
        suspend fun proceed(): ImageResult
        suspend fun proceed(request: ImageRequest): ImageResult
    }
}
