package androidx.room

@Target(AnnotationTarget.ANNOTATION_CLASS)
annotation class ForeignKey(val entity: kotlin.reflect.KClass<*> = Any::class, val parentColumns: Array<String> = [], val childColumns: Array<String> = [], val onDelete: Int = 0, val onUpdate: Int = 0)
