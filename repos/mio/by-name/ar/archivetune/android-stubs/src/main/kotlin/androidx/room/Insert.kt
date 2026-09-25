package androidx.room

@Target(AnnotationTarget.FUNCTION)
annotation class Insert(val onConflict: Int = 0)
