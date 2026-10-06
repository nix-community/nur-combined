package androidx.media3.exoplayer.scheduler

/*
 * Upstream constructs it as PlatformScheduler(this, JOB_ID); the earlier stub had no
 * constructor, so that call was "too many arguments".
 */
class PlatformScheduler(
    context: Any?,
    jobId: Int,
) : Scheduler {
    override fun schedule(requirements: Any): Boolean = true

    override fun cancel(): Boolean = true
}
