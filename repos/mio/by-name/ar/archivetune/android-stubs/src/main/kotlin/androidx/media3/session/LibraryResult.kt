package androidx.media3.session

import androidx.media3.common.MediaItem

open class LibraryResult<T> {
    companion object {
        fun <T> ofItem(item: T, params: Any?): LibraryResult<T> = LibraryResult()
        fun <T> ofItemList(items: List<T>, params: Any?): LibraryResult<List<T>> = LibraryResult()
        fun <T> ofError(errorCode: Int): LibraryResult<T> = LibraryResult()
        
        const val RESULT_ERROR_NOT_SUPPORTED = -1
        const val RESULT_ERROR_BAD_VALUE = -2
    }
}
