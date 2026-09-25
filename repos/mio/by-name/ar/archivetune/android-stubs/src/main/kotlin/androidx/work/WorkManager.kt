package androidx.work
open class WorkManager {
    companion object {
        fun getInstance(context: android.content.Context): WorkManager = WorkManager()
    }
    fun enqueueUniqueWork(name: String, policy: ExistingWorkPolicy, request: Any) {}
    fun cancelUniqueWork(name: String) {}
}
