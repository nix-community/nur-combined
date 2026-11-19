package androidx.core.app

import android.app.Activity

object ActivityCompat {
    @JvmStatic
    fun shouldShowRequestPermissionRationale(activity: Activity?, permission: String): Boolean = false
}
