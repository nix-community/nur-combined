package androidx.room

annotation class RenameColumn(
    val tableName: String,
    val fromColumnName: String,
    val toColumnName: String,
) {
    annotation class Entries(vararg val value: RenameColumn)
}
