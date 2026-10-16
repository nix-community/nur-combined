package androidx.datastore.preferences

import android.content.Context
import androidx.datastore.core.DataMigration
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.MutablePreferences
import androidx.datastore.preferences.core.Preferences
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.Properties
import kotlin.properties.ReadOnlyProperty
import kotlinx.coroutines.flow.MutableStateFlow

object DesktopPreferenceStore {
    private val configFile: File by lazy {
        val configHome = System.getenv("XDG_CONFIG_HOME")?.takeIf { it.isNotBlank() }
            ?: (System.getProperty("user.home") + File.separator + ".config")
        val dir = File(configHome, "archivetune").apply { mkdirs() }
        File(dir, "preferences.properties")
    }

    val currentPreferences: MutablePreferences = MutablePreferences()
    val preferencesFlow: MutableStateFlow<Preferences>

    init {
        loadFromDisk()
        preferencesFlow = MutableStateFlow(currentPreferences.toMutablePreferences())
    }

    private fun loadFromDisk() {
        try {
            if (configFile.exists()) {
                val prop = Properties()
                FileInputStream(configFile).use { prop.load(it) }
                for (name in prop.stringPropertyNames()) {
                    val v = prop.getProperty(name)
                    if (v != null) {
                        currentPreferences.values[name] = v
                    }
                }
            }
        } catch (e: Throwable) {
            System.err.println("[DesktopPreferenceStore] Error loading preferences: ${e.message}")
        }
    }

    fun saveToDisk() {
        try {
            val prop = Properties()
            for ((k, v) in currentPreferences.values) {
                prop.setProperty(k, v.toString())
            }
            FileOutputStream(configFile).use { prop.store(it, "ArchiveTune Desktop Preferences") }
        } catch (e: Throwable) {
            System.err.println("[DesktopPreferenceStore] Error saving preferences: ${e.message}")
        }
    }

    fun notifyChanged() {
        preferencesFlow.value = currentPreferences.toMutablePreferences()
    }
}

fun preferencesDataStore(
    name: String,
    produceMigrations: (Context) -> List<DataMigration<Preferences>> = { emptyList() }
): ReadOnlyProperty<Context, DataStore<Preferences>> = ReadOnlyProperty { _, _ ->
    object : DataStore<Preferences> {
        override val data: kotlinx.coroutines.flow.Flow<Preferences> get() = DesktopPreferenceStore.preferencesFlow
    }
}
