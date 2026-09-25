package androidx.datastore.preferences.core

import androidx.datastore.core.DataStore

suspend fun DataStore<Preferences>.edit(transform: suspend (MutablePreferences) -> Unit): Preferences = TODO()
