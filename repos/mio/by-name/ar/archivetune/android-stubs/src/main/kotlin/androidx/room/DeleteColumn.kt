package androidx.room

annotation class DeleteColumn(val tableName: String, val columnName: String) {
    annotation class Entries(vararg val value: DeleteColumn)
}
