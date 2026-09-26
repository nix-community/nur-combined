package androidx.room

@Target(AnnotationTarget.FIELD, AnnotationTarget.PROPERTY)
annotation class Relation(
    val parentColumn: String = "",
    val entityColumn: String = "",
    val entity: kotlin.reflect.KClass<*> = Any::class,
    val associateBy: Junction = Junction(),
    val projection: Array<String> = []
)
