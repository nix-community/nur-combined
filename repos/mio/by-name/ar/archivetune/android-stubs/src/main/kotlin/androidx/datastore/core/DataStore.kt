package androidx.datastore.core


interface DataStore<T> {
    val data: kotlinx.coroutines.flow.Flow<T>
}

