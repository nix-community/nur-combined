package androidx.work
import java.util.concurrent.TimeUnit
open class OneTimeWorkRequest {
    open class Builder {
        fun setConstraints(constraints: Constraints): Builder = this
        fun setInitialDelay(duration: Long, timeUnit: TimeUnit): Builder = this
        fun build(): OneTimeWorkRequest = OneTimeWorkRequest()
    }
}
inline fun <reified T> OneTimeWorkRequestBuilder(): OneTimeWorkRequest.Builder = OneTimeWorkRequest.Builder()
