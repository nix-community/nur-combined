package androidx.car.app.connection

import android.content.Context
import androidx.lifecycle.LiveData

// androidx.car.app.connection.CarConnection reports whether the app is projected
// onto a car head unit. It is an Android-only API with no desktop equivalent, so
// the port reports "never connected".
open class CarConnection(context: Context) {
    val type: LiveData<Int> = LiveData()

    companion object {
        const val CONNECTION_TYPE_NATIVE = 1
        const val CONNECTION_TYPE_PROJECTION = 2
    }
}
