package androidx.room

@Target(AnnotationTarget.FUNCTION)
annotation class Query(val value: String = "")
