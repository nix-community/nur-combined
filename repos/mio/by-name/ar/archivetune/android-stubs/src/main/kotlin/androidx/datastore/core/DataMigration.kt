package androidx.datastore.core

interface DataMigration<T> {
    suspend fun shouldMigrate(currentData: T): Boolean = true
    suspend fun migrate(currentData: T): T
    suspend fun cleanUp() {}
}
