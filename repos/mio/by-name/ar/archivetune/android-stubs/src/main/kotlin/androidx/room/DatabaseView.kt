package androidx.room

@Target(AnnotationTarget.CLASS)
annotation class DatabaseView(val value: String = "", val viewName: String = "")
