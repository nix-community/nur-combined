package androidx.room

@Target(AnnotationTarget.FIELD, AnnotationTarget.PROPERTY)
annotation class ColumnInfo(val name: String = "", val defaultValue: String = "")
