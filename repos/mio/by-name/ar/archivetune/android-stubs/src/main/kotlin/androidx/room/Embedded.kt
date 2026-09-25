package androidx.room

@Target(AnnotationTarget.FIELD, AnnotationTarget.PROPERTY)
annotation class Embedded(val prefix: String = "")
