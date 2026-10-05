package androidx.work

open class WorkManager {
    companion object {
        fun getInstance(context: android.content.Context): WorkManager = WorkManager()
    }
    open fun enqueueUniquePeriodicWork(uniqueWorkName: String, existingPeriodicWorkPolicy: ExistingPeriodicWorkPolicy, periodicWork: PeriodicWorkRequest) {}
    open fun enqueueUniqueWork(uniqueWorkName: String, existingWorkPolicy: ExistingWorkPolicy, work: OneTimeWorkRequest) {}
    open fun cancelUniqueWork(uniqueWorkName: String) {}
}

open class PeriodicWorkRequest {
    open class Builder(workerClass: Class<out ListenableWorker>, repeatInterval: Long, repeatIntervalTimeUnit: java.util.concurrent.TimeUnit) {
        open fun setConstraints(constraints: Constraints): Builder = this
        open fun build(): PeriodicWorkRequest = PeriodicWorkRequest()
    }
}
