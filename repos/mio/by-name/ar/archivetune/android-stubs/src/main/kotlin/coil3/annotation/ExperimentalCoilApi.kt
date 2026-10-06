package coil3.annotation

/* Coil's opt-in marker; upstream uses it as @OptIn(ExperimentalCoilApi::class), so it must be a
 * real annotation rather than a class. */
@RequiresOptIn(message = "This Coil API is experimental and may change.")
@Retention(AnnotationRetention.BINARY)
@Target(
    AnnotationTarget.CLASS,
    AnnotationTarget.FUNCTION,
    AnnotationTarget.PROPERTY,
)
annotation class ExperimentalCoilApi
