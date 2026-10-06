package androidx.room

/*
 * Room's @Index annotation. Upstream writes `indices = [Index("targetId")]`, so value must be a
 * vararg (an Array<String> parameter would need arrayOf(...)).
 */
@Retention(AnnotationRetention.BINARY)
@Target(AnnotationTarget.CLASS)
annotation class Index(
    vararg val value: String,
    val unique: Boolean = false,
    val orders: IntArray = intArrayOf(),
)
