package androidx.lifecycle

// Minimal LiveData/Observer surface: android.car's CarConnection exposes a
// LiveData<Int> that the app observes to track Android Auto connectivity.
open class LiveData<T> {
    open val value: T? = null

    open fun observeForever(observer: Observer<in T>) {}

    open fun removeObserver(observer: Observer<in T>) {}

    open fun observe(owner: Any, observer: Observer<in T>) {}
}

fun interface Observer<T> {
    fun onChanged(value: T)
}
