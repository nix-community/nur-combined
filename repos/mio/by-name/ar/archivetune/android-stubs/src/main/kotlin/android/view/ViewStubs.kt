package android.view

import android.content.Context
import android.graphics.Bitmap
import android.graphics.SurfaceTexture
import android.os.Handler

interface ViewParent

open class ViewGroup(context: Context) : View(context), ViewParent {
    open class LayoutParams(var width: Int = 0, var height: Int = 0) {
        companion object {
            const val MATCH_PARENT = -1
            const val WRAP_CONTENT = -2
        }
    }

    open fun addView(child: View) {}
    open fun addView(child: View, params: LayoutParams) {}
    open fun removeView(child: View) {}
    open fun removeAllViews() {}
    open val childCount: Int get() = 0
    open fun getChildAt(index: Int): View? = null
}

open class Surface(surfaceTexture: SurfaceTexture? = null) {
    fun release() {}
}

open class TextureView(context: Context) : View(context) {
    var surfaceTextureListener: SurfaceTextureListener? = null
    val surfaceTexture: SurfaceTexture? = null
    var isOpaque: Boolean = true
    val isAvailable: Boolean get() = true

    fun getBitmap(width: Int, height: Int): Bitmap? = null
    fun setTransform(transform: android.graphics.Matrix?) {}

    interface SurfaceTextureListener {
        fun onSurfaceTextureAvailable(surface: SurfaceTexture, width: Int, height: Int)
        fun onSurfaceTextureSizeChanged(surface: SurfaceTexture, width: Int, height: Int)
        fun onSurfaceTextureDestroyed(surface: SurfaceTexture): Boolean
        fun onSurfaceTextureUpdated(surface: SurfaceTexture)
    }
}

open class ViewConfiguration {
    companion object {
        private val instance = ViewConfiguration()
        @JvmStatic
        fun get(context: Context): ViewConfiguration = instance
        @JvmStatic
        fun getLongPressTimeout(): Int = 400
        @JvmStatic
        fun getDoubleTapTimeout(): Int = 300
    }

    val scaledTouchSlop: Int = 8
}

open class Window {
    fun addFlags(flags: Int) {}
    fun clearFlags(flags: Int) {}
    var attributes: WindowManager.LayoutParams = WindowManager.LayoutParams()
}

open class WindowManager {
    open class LayoutParams {
        var flags: Int = 0
        var preferredDisplayModeId: Int = 0
        var preferredRefreshRate: Float = 0f

        companion object {
            const val FLAG_KEEP_SCREEN_ON = 128
        }
    }
}

open class PixelCopy {
    companion object {
        const val SUCCESS = 0
        const val ERROR_UNKNOWN = 1
        @JvmStatic
        fun request(source: Surface, dest: Bitmap, listener: OnPixelCopyFinishedListener, handler: Handler) {
            listener.onPixelCopyFinished(SUCCESS)
        }
    }

    interface OnPixelCopyFinishedListener {
        fun onPixelCopyFinished(copyResult: Int)
    }
}

object KeyEvent {
    const val KEYCODE_DPAD_CENTER = 23
    const val KEYCODE_ENTER = 66
    const val KEYCODE_NUMPAD_ENTER = 160
}
