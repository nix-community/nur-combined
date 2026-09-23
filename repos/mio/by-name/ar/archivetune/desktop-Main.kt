package moe.rukamori.archivetune.desktop

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application
import androidx.compose.ui.window.rememberWindowState
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import moe.rukamori.archivetune.innertube.YouTube

fun main() = application {
    moe.rukamori.archivetune.innertube.NetworkGatekeeper.setConnectionBlocked(false)
    val windowState = rememberWindowState(width = 1200.dp, height = 800.dp)

    Window(
        onCloseRequest = ::exitApplication,
        title = "ArchiveTune",
        state = windowState,
    ) {
        MaterialTheme(
            colorScheme = darkColorScheme(),
        ) {
            ArchiveTuneApp()
        }
    }
}

@Composable
fun ArchiveTuneApp() {
    val scope = rememberCoroutineScope()
    var searchQuery by remember { mutableStateOf("") }
    var searchResults by remember { mutableStateOf(listOf<String>()) }
    var isLoading by remember { mutableStateOf(false) }
    var statusMessage by remember { mutableStateOf("Welcome to ArchiveTune Desktop") }

    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background,
    ) {
        Column(
            modifier = Modifier.fillMaxSize().padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Text(
                text = "🌸 ArchiveTune",
                style = MaterialTheme.typography.headlineLarge,
                color = MaterialTheme.colorScheme.primary,
            )

            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.fillMaxWidth(),
            ) {
                OutlinedTextField(
                    value = searchQuery,
                    onValueChange = { searchQuery = it },
                    label = { Text("Search YouTube Music") },
                    modifier = Modifier.weight(1f),
                    singleLine = true,
                )
                Button(
                    onClick = {
                        if (searchQuery.isNotBlank()) {
                            isLoading = true
                            searchResults = emptyList()
                            scope.launch(Dispatchers.IO) {
                                val result = YouTube.search(searchQuery, YouTube.SearchFilter.FILTER_SONG)
                                result.onSuccess { page ->
                                    searchResults = page.items.map { it.toString() }
                                    statusMessage = "Found ${searchResults.size} results"
                                }.onFailure { err ->
                                    statusMessage = "Error: ${err.message}"
                                }
                                isLoading = false
                            }
                        }
                    },
                    enabled = !isLoading,
                    modifier = Modifier.align(Alignment.CenterVertically)
                ) { Text(if (isLoading) "Searching…" else "Search") }
            }

            Text(
                text = statusMessage,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )

            if (isLoading) {
                LinearProgressIndicator(modifier = Modifier.fillMaxWidth())
            }

            LazyColumnResults(searchResults)
        }
    }
}

@Composable
fun LazyColumnResults(items: List<String>) {
    if (items.isEmpty()) return
    LazyColumn(
        modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
        verticalArrangement = Arrangement.spacedBy(4.dp),
    ) {
        items(items) { item ->
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant,
                ),
            ) {
                Text(
                    text = item,
                    modifier = Modifier.padding(12.dp),
                    style = MaterialTheme.typography.bodyMedium,
                )
            }
        }
    }
}
