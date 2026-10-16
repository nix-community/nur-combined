package androidx.datastore.preferences.core

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.DesktopPreferenceStore

suspend fun DataStore<Preferences>.edit(transform: suspend (MutablePreferences) -> Unit): Preferences {
    val store = DesktopPreferenceStore
    transform(store.currentPreferences)
    store.saveToDisk()
    store.notifyChanged()
    return store.currentPreferences.toMutablePreferences()
}
