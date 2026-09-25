package androidx.room

@Target(AnnotationTarget.ANNOTATION_CLASS)
annotation class AutoMigration(val from: Int = 0, val to: Int = 0)
