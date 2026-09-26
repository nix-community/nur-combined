package androidx.room

@Target(AnnotationTarget.ANNOTATION_CLASS)
annotation class Junction(
    val value: kotlin.reflect.KClass<*> = Any::class,
    val parentColumn: String = "",
    val entityColumn: String = ""
)
