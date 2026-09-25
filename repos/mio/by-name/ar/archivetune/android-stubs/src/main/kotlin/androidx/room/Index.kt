package androidx.room

@Target(AnnotationTarget.CLASS, AnnotationTarget.ANNOTATION_CLASS)
annotation class Index(val value: Array<String> = [], val unique: Boolean = false, val orders: IntArray = intArrayOf())
