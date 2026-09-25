package androidx.room

@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION, AnnotationTarget.FIELD, AnnotationTarget.PROPERTY)
annotation class TypeConverters(vararg val value: kotlin.reflect.KClass<*>)
