package androidx.annotation

/* androidx.annotation's threading markers; upstream uses them as annotations. */
@Retention(AnnotationRetention.BINARY)
@Target(
    AnnotationTarget.FUNCTION,
    AnnotationTarget.PROPERTY,
    AnnotationTarget.PROPERTY_GETTER,
    AnnotationTarget.CLASS,
    AnnotationTarget.CONSTRUCTOR,
)
annotation class WorkerThread
