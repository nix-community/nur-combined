package androidx.media3.common.util

import android.net.Uri
import android.graphics.Bitmap
import com.google.common.util.concurrent.ListenableFuture

interface BitmapLoader {
    fun decodeBitmap(data: ByteArray): ListenableFuture<Bitmap>
    fun loadBitmap(uri: Uri): ListenableFuture<Bitmap>
    fun supportsMimeType(mimeType: String): Boolean = true
}
