package androidx.work

inline fun <reified W : ListenableWorker> PeriodicWorkRequestBuilder(
    repeatInterval: Long,
    repeatIntervalTimeUnit: java.util.concurrent.TimeUnit
): PeriodicWorkRequest.Builder = PeriodicWorkRequest.Builder(W::class.java, repeatInterval, repeatIntervalTimeUnit)

inline fun <reified W : ListenableWorker> PeriodicWorkRequestBuilder(
    repeatInterval: Int,
    repeatIntervalTimeUnit: java.util.concurrent.TimeUnit
): PeriodicWorkRequest.Builder = PeriodicWorkRequest.Builder(W::class.java, repeatInterval.toLong(), repeatIntervalTimeUnit)

inline fun <reified W : ListenableWorker> PeriodicWorkRequestBuilder(
    repeatInterval: Long,
    repeatIntervalTimeUnit: java.util.concurrent.TimeUnit,
    flexInterval: Long,
    flexIntervalTimeUnit: java.util.concurrent.TimeUnit
): PeriodicWorkRequest.Builder = PeriodicWorkRequest.Builder(W::class.java, repeatInterval, repeatIntervalTimeUnit)
