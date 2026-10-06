package androidx.room

/*
 * Room's @DeleteTable annotation. Upstream uses it as
 * `@DeleteTable.Entries(DeleteTable(tableName = "download"))`, so the annotation needs its
 * tableName parameter and a nested Entries container.
 */
@Retention(AnnotationRetention.BINARY)
@Target(AnnotationTarget.CLASS)
annotation class DeleteTable(
    val tableName: String = "",
    val entity: kotlin.reflect.KClass<*> = Unit::class,
) {
    /* Upstream writes @DeleteTable.Entries(DeleteTable(tableName = "...")). */
    @Retention(AnnotationRetention.BINARY)
    @Target(AnnotationTarget.CLASS)
    annotation class Entries(vararg val value: DeleteTable)
}
