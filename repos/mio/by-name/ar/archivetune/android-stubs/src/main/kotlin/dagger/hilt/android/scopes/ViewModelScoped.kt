package dagger.hilt.android.scopes

/* Hilt scope annotation; the port has no Hilt codegen, so it only needs to exist. */
@Target(
    AnnotationTarget.CLASS,
    AnnotationTarget.FUNCTION,
    AnnotationTarget.PROPERTY,
    AnnotationTarget.PROPERTY_GETTER,
    AnnotationTarget.VALUE_PARAMETER,
)
@Retention(AnnotationRetention.RUNTIME)
annotation class ViewModelScoped
