package androidx.room

@Target(AnnotationTarget.FUNCTION)
annotation class Update(val onConflict: Int = 0)
