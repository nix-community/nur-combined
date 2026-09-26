package androidx.room

@Target(AnnotationTarget.ANNOTATION_CLASS)
annotation class ForeignKey(
    val entity: kotlin.reflect.KClass<*> = Any::class,
    val parentColumns: Array<String> = [],
    val childColumns: Array<String> = [],
    val onDelete: Int = 0,
    val onUpdate: Int = 0
) {
    companion object {
        const val NO_ACTION = 1
        const val RESTRICT = 2
        const val SET_NULL = 3
        const val SET_DEFAULT = 4
        const val CASCADE = 5
    }
}
