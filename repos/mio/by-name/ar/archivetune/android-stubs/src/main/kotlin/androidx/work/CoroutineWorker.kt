package androidx.work

open class ListenableWorker {
    open class Result {
        companion object {
            fun success(): Result = Result()
            fun failure(): Result = Result()
            fun retry(): Result = Result()
        }
    }
}

open class CoroutineWorker(val applicationContext: android.content.Context, params: WorkerParameters) : ListenableWorker() {
    open suspend fun doWork(): Result = Result.success()
}

