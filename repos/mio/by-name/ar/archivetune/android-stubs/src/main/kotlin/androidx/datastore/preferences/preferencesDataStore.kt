package androidx.datastore.preferences

import android.content.Context
import androidx.datastore.core.DataMigration
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import kotlin.properties.ReadOnlyProperty

fun preferencesDataStore(
    name: String,
    produceMigrations: (Context) -> List<DataMigration<Preferences>> = { emptyList() }
): ReadOnlyProperty<Context, DataStore<Preferences>> = ReadOnlyProperty { _, _ -> TODO() }
