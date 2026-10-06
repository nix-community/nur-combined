package androidx.media3.exoplayer.scheduler

/* Job-scheduling contract used by DownloadService (Scheduler is an interface in media3). */
interface Scheduler {
    fun schedule(requirements: Any): Boolean

    fun cancel(): Boolean

    fun getSupportedRequirements(requirements: Any): Any? = null
}
