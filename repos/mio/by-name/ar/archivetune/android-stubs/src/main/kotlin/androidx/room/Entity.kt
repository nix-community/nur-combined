package androidx.room

@Target(AnnotationTarget.CLASS)
annotation class Entity(
    val tableName: String = "",
    val primaryKeys: Array<String> = [],
    val indices: Array<Index> = [],
    val foreignKeys: Array<ForeignKey> = []
)
